local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action

local config = wezterm.config_builder()

-- ─── Project definitions ─────────────────────────────────────────────

local function dev_server_command()
  return 'foreman start -f Procfile.dev -m all=1,web=0'
end

-- Shared claude/editor/diff/shell layout. `claude_side` is the command run
-- in the claude tab's right pane (typically `subsequent`, with optional args).
local function base_tabs(claude_side)
  return {
    {
      title = 'claude',
      panes = {
        { cmd = 'claude' },
        { cmd = claude_side, split = { direction = 'Right', size = 0.4 } },
      },
    },
    {
      title = 'editor',
      panes = {
        { cmd = 'vim' },
        { split = { direction = 'Right', size = 0.4 } },
      },
    },
    { title = 'diff',  panes = { {} } },
    { title = 'shell', panes = { {} } },
  }
end

local function subsequent_cmd(args)
  return args and ('subsequent ' .. args) or 'subsequent'
end

local function simple_project(cwd, opts)
  opts = opts or {}
  return { cwd = cwd, tabs = base_tabs(subsequent_cmd(opts.subsequent)) }
end

local function rails_project(cwd, opts)
  opts = opts or {}
  local tabs = base_tabs(subsequent_cmd(opts.subsequent))
  table.insert(tabs, { title = 'server', panes = { { cmd = dev_server_command() } } })
  if opts.redis then
    table.insert(tabs, { title = 'redis', panes = { { cmd = 'redis-server' } } })
  end
  return { cwd = cwd, tabs = tabs }
end

-- ─── Project discovery ───────────────────────────────────────────────
-- Each project opts in by dropping a `.wezterm-project.lua` at its root that
-- returns a descriptor: { kind = 'rails', redis = true } or { kind = 'simple' }.
-- Workspace name = basename of the project directory. Scan is depth-limited
-- so we never descend into node_modules/vendor/etc.

local kinds = {
  rails  = rails_project,
  simple = simple_project,
}

local function discover_projects(root, max_depth)
  local found = {}
  for depth = 1, max_depth do
    local pattern = root .. string.rep('/*', depth) .. '/.wezterm-project.lua'
    for _, cfg in ipairs(wezterm.glob(pattern)) do
      local dir  = cfg:match('(.+)/[^/]+$')
      local name = dir:match('([^/]+)$')
      local ok, d = pcall(dofile, cfg)
      if not (ok and type(d) == 'table') then
        error('Failed to load ' .. cfg .. ': ' .. tostring(d))
      elseif not kinds[d.kind] then
        error(cfg .. ': unknown kind ' .. tostring(d.kind))
      else
        found[name] = kinds[d.kind](dir, d)
      end
    end
  end
  return found
end

local projects = discover_projects(wezterm.home_dir .. '/Dropbox/projects', 3)

-- ─── Layout materialization ──────────────────────────────────────────

local function send_cmd(pane, cmd)
  if cmd then pane:send_text(cmd .. '\n') end
end

local function populate_tab(tab, main_pane, tab_def, cwd)
  if tab_def.title then tab:set_title(tab_def.title) end
  local panes = tab_def.panes or { {} }
  send_cmd(main_pane, panes[1].cmd)
  for i = 2, #panes do
    local p = panes[i]
    local s = p.split or { direction = 'Right', size = 0.4 }
    local new_pane = main_pane:split { direction = s.direction, size = s.size, cwd = cwd }
    send_cmd(new_pane, p.cmd)
  end
  main_pane:activate()
end

local function materialize_project(name, project)
  local first_tab, first_pane, window = mux.spawn_window {
    workspace = name,
    cwd = project.cwd,
  }
  populate_tab(first_tab, first_pane, project.tabs[1], project.cwd)
  for i = 2, #project.tabs do
    local tab, pane = window:spawn_tab { cwd = project.cwd }
    populate_tab(tab, pane, project.tabs[i], project.cwd)
  end
end

local function workspace_exists(name)
  for _, ws in ipairs(mux.get_workspace_names()) do
    if ws == name then return true end
  end
  return false
end

local mru_path = wezterm.home_dir .. '/.local/state/wezterm/mru.json'

-- Load persisted MRU, pruning entries whose projects no longer exist.
local function mru_load()
  local list = {}
  local f = io.open(mru_path, 'r')
  if not f then return list end
  local body = f:read('*a')
  f:close()
  local ok, decoded = pcall(wezterm.json_parse, body)
  if ok and type(decoded) == 'table' then
    for _, name in ipairs(decoded) do
      if projects[name] then table.insert(list, name) end
    end
  end
  return list
end

local mru = mru_load()

local function mru_save()
  local f = io.open(mru_path, 'w')
  if not f then
    wezterm.run_child_process { 'mkdir', '-p', mru_path:match('(.+)/[^/]+$') }
    f = io.open(mru_path, 'w')
    if not f then return end
  end
  f:write(wezterm.json_encode(mru))
  f:close()
end

local function mru_touch(name)
  for i, n in ipairs(mru) do
    if n == name then table.remove(mru, i); break end
  end
  table.insert(mru, 1, name)
  mru_save()
end

local function mru_remove(name)
  for i, n in ipairs(mru) do
    if n == name then table.remove(mru, i); mru_save(); return end
  end
end

-- Workspaces registered via launch-here. Tracked so they can be pruned from
-- the MRU on close — committed projects stay in the MRU for easy re-launch.
local ephemeral = {}

local function switch_or_launch(window, name)
  local was_new = false
  if not workspace_exists(name) then
    local project = projects[name]
    if not project then
      wezterm.log_error('Unknown workspace/project: ' .. tostring(name))
      return
    end
    materialize_project(name, project)
    was_new = true
  end
  mru_touch(name)
  window:perform_action(act.SwitchToWorkspace { name = name }, window:active_pane())
  -- SwitchToWorkspace preserves the caller GUI window's active-tab *index*,
  -- ignoring the new workspace's mux state. Reset to tab 0 for fresh launches.
  if was_new then
    window:perform_action(act.ActivateTab(0), window:active_pane())
  end
end

-- ─── Close workspace ─────────────────────────────────────────────────

local function kill_workspace(ws)
  for _, mux_win in ipairs(mux.all_windows()) do
    if mux_win:get_workspace() == ws then
      for _, tab in ipairs(mux_win:tabs()) do
        for _, p in ipairs(tab:panes()) do
          wezterm.run_child_process {
            'wezterm', 'cli', 'kill-pane', '--pane-id=' .. tostring(p:pane_id()),
          }
        end
      end
    end
  end
end

-- Foreground process name → graceful shutdown action. Default (no entry) is
-- Ctrl-C, which is fine for most CLI tools. Names are basenames as reported
-- by pane:get_foreground_process_info().
local shutdown_strategies = {
  claude           = { kind = 'send_seq', keys = { '\x04', '\x04' }, gap_ms = 150 },
  vim              = { kind = 'send', text = '\x1b:wqa\r' },
  nvim             = { kind = 'send', text = '\x1b:wqa\r' },
  ['redis-server'] = { kind = 'cmd',  cmd = 'redis-cli shutdown nosave 2>/dev/null' },
  foreman          = { kind = 'send', text = '\x03' },
  ruby             = { kind = 'send', text = '\x03' },
  bash             = { kind = 'send', text = '\x04' },
  zsh              = { kind = 'send', text = '\x04' },
}
local default_strategy = { kind = 'send', text = '\x03' }
local idle_names = { bash = true, zsh = true, sh = true, dash = true, fish = true }

local function fg_process_name(pane)
  local ok, info = pcall(function() return pane:get_foreground_process_info() end)
  if ok and info and info.name then return info.name end
  return nil
end

local function trigger_shutdown(pane, project_cwd)
  local name = fg_process_name(pane)
  if not name then return false end
  local s = shutdown_strategies[name] or default_strategy
  if s.kind == 'send' then
    pane:send_text(s.text)
  elseif s.kind == 'send_seq' then
    pane:send_text(s.keys[1])
    if s.gap_ms and #s.keys > 1 then
      wezterm.run_child_process { 'sleep', tostring(s.gap_ms / 1000) }
    end
    for i = 2, #s.keys do pane:send_text(s.keys[i]) end
  elseif s.kind == 'cmd' then
    if project_cwd then
      wezterm.run_child_process { 'mise', 'exec', '--cd', project_cwd, '--', 'bash', '-c', s.cmd }
    else
      wezterm.run_child_process { 'bash', '-c', s.cmd }
    end
  end
  return true
end

local function pane_idle(pane)
  local name = fg_process_name(pane)
  return name == nil or idle_names[name] == true
end

local function close_one(ws)
  local project = projects[ws]
  local cwd = project and project.cwd or nil

  -- Trigger graceful shutdown on every pane that has something running.
  local draining = {}
  for _, mux_win in ipairs(mux.all_windows()) do
    if mux_win:get_workspace() == ws then
      for _, tab in ipairs(mux_win:tabs()) do
        for _, p in ipairs(tab:panes()) do
          if trigger_shutdown(p, cwd) then table.insert(draining, p) end
        end
      end
    end
  end

  -- Drain: poll up to 5s for triggered panes to reach a shell prompt.
  for _ = 1, 25 do
    local all_idle = true
    for _, p in ipairs(draining) do
      if not pane_idle(p) then all_idle = false; break end
    end
    if all_idle then break end
    wezterm.run_child_process { 'sleep', '0.2' }
  end

  kill_workspace(ws)
  if ephemeral[ws] then mru_remove(ws) end
end

-- Pick the next workspace to focus after closing one (or many): first active
-- entry in MRU order that isn't in the excluded set, else 'default'.
local function next_focus(excluded)
  local active = {}
  for _, w in ipairs(mux.get_workspace_names()) do active[w] = true end
  for _, name in ipairs(mru) do
    if active[name] and not excluded[name] then return name end
  end
  return 'default'
end

wezterm.on('close-workspace', function(window, pane)
  local ws = window:active_workspace()
  local active_projects = {}
  for _, name in ipairs(mux.get_workspace_names()) do
    if projects[name] then table.insert(active_projects, name) end
  end

  local choices = {
    { label = 'No',  id = 'no' },
    { label = 'Yes — shut down & kill panes', id = 'yes' },
  }
  if #active_projects > 1 then
    table.insert(choices, {
      label = 'Yes — close ALL projects (' .. #active_projects .. ')',
      id = 'all',
    })
  end

  window:perform_action(
    act.InputSelector {
      title = 'Close workspace "' .. ws .. '"?',
      choices = choices,
      action = wezterm.action_callback(function(win, _p, id, _label)
        if id == 'yes' then
          -- Switch away before killing panes so we land deterministically
          -- instead of wherever wezterm picks when the active ws dissolves.
          local target = next_focus { [ws] = true }
          mru_touch(target)
          win:perform_action(
            act.SwitchToWorkspace { name = target },
            win:active_pane()
          )
          close_one(ws)
        elseif id == 'all' then
          local excluded = {}
          for _, name in ipairs(active_projects) do excluded[name] = true end
          local target = next_focus(excluded)
          mru_touch(target)
          win:perform_action(
            act.SwitchToWorkspace { name = target },
            win:active_pane()
          )
          for _, name in ipairs(active_projects) do close_one(name) end
        end
      end),
    },
    pane
  )
end)

-- ─── Launcher ────────────────────────────────────────────────────────

wezterm.on('launch-project', function(window, pane)
  local current = window:active_workspace()
  local active = {}
  for _, ws in ipairs(mux.get_workspace_names()) do active[ws] = true end

  -- Walk MRU first so closed projects keep their slot; a closed entry shows
  -- with '(launch)' so it's visually distinct from an active workspace.
  local choices = {}
  local seen = {}
  -- Current workspace always shown first. `default` and ad-hoc workspaces may
  -- not be in MRU yet on a fresh session.
  table.insert(choices, { label = '● ' .. current, id = current })
  seen[current] = true
  for _, ws in ipairs(mru) do
    if not seen[ws] then
      seen[ws] = true
      if active[ws] then
        table.insert(choices, { label = '○ ' .. ws, id = ws })
      elseif projects[ws] then
        table.insert(choices, { label = '  ' .. ws .. '  (launch)', id = ws })
      end
    end
  end
  for _, ws in ipairs(mux.get_workspace_names()) do
    if not seen[ws] then
      seen[ws] = true
      table.insert(choices, { label = '○ ' .. ws, id = ws })
    end
  end
  for name, _ in pairs(projects) do
    if not seen[name] then
      table.insert(choices, { label = '  ' .. name .. '  (launch)', id = name })
    end
  end

  window:perform_action(
    act.InputSelector {
      title = 'Switch / launch workspace',
      choices = choices,
      action = wezterm.action_callback(function(win, _p, id, _label)
        if id then switch_or_launch(win, id) end
      end),
    },
    pane
  )
end)

-- ─── Ad-hoc launch (no .wezterm-project.lua required) ───────────────
-- For directories without a committed project descriptor — a freshly-cloned
-- repo, a bundled gem's checkout — spin up a `simple` workspace from $PWD.

local function pane_cwd(pane)
  local url = pane:get_current_working_dir()
  if not url then return nil end
  if type(url) == 'string' then
    return url:match('^file://[^/]*(/.*)$') or url
  end
  return url.file_path
end

wezterm.on('launch-here', function(window, pane)
  local cwd = pane_cwd(pane)
  if not cwd or cwd == '' then
    wezterm.log_error('launch-here: could not read cwd from active pane')
    return
  end
  local name = cwd:match('([^/]+)$')
  if not name then
    wezterm.log_error('launch-here: could not derive name from cwd ' .. cwd)
    return
  end
  -- A pre-registered project at this name wins over the ad-hoc descriptor.
  if not projects[name] then
    projects[name] = simple_project(cwd)
    ephemeral[name] = true
  end
  switch_or_launch(window, name)
end)

-- ─── Startup ─────────────────────────────────────────────────────────

wezterm.on('gui-startup', function(cmd)
  local _, pane, window = mux.spawn_window(cmd or {})
  local right = pane:split { direction = 'Right', size = 0.4 }
  right:send_text('subsequent\n')
  pane:activate()
  window:gui_window():maximize()
end)

-- ─── Keys ────────────────────────────────────────────────────────────

config.keys = {
  { key = 'S', mods = 'CTRL|SHIFT', action = act.EmitEvent 'launch-project' },
  { key = 'O', mods = 'CTRL|SHIFT', action = act.EmitEvent 'launch-here' },
  { key = 'Q', mods = 'CTRL|SHIFT', action = act.EmitEvent 'close-workspace' },
}

-- ─── Appearance ──────────────────────────────────────────────────────

config.font = wezterm.font_with_fallback {
  'JetBrains Mono',
  'Hack Nerd Font Mono',
}

config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.5,
}

return config
