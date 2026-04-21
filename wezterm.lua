local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action

local config = wezterm.config_builder()

-- ─── Project definitions ─────────────────────────────────────────────

-- Bind overmind's socket at an ABSOLUTE path (via OVERMIND_SOCKET) so that
-- /proc/net/unix records a unique per-project path.
local function overmind_command(cwd)
  local sock = cwd .. '/.overmind.sock'
  return 'OVERMIND_SOCKET=' .. sock .. ' overmind start -f Procfile.dev -x web'
end

-- Graceful shutdown: ask overmind to quit, wait for it to remove its socket,
-- then (optionally) stop redis. Run before killing panes on workspace close.
local function rails_teardown(cwd, opts)
  local sock = cwd .. '/.overmind.sock'
  local parts = {
    'OVERMIND_SOCKET=' .. sock .. ' overmind quit 2>/dev/null',
    "timeout 5 bash -c 'while [ -S " .. sock .. " ]; do sleep 0.1; done'",
  }
  if opts.redis then
    table.insert(parts, 'redis-cli shutdown nosave 2>/dev/null')
  end
  return table.concat(parts, '; ')
end

-- Non-rails project: claude/subsequent, vim/bash, diff, shell. No server/teardown.
local function simple_project(cwd)
  local tabs = {
    {
      title = 'claude',
      panes = {
        { cmd = 'claude' },
        { cmd = 'subsequent', split = { direction = 'Right', size = 0.4 } },
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
  return { cwd = cwd, tabs = tabs }
end

local function rails_project(cwd, opts)
  opts = opts or {}
  local tabs = {
    {
      title = 'claude',
      panes = {
        { cmd = 'claude' },
        { cmd = { 'subsequent', 'bl3' }, split = { direction = 'Right', size = 0.4 } },
      },
    },
    {
      title = 'editor',
      panes = {
        { cmd = 'vim' },
        { split = { direction = 'Right', size = 0.4 } },
      },
    },
    { title = 'diff',   panes = { {} } },
    { title = 'shell',  panes = { {} } },
    { title = 'server', panes = { { cmd = overmind_command(cwd) } } },
  }
  if opts.redis then
    table.insert(tabs, { title = 'redis', panes = { { cmd = 'redis-server' } } })
  end
  return { cwd = cwd, tabs = tabs, teardown = rails_teardown(cwd, opts) }
end

-- ─── Project discovery ───────────────────────────────────────────────
-- Each project opts in by dropping a `.wezterm.lua` at its root that
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
    local pattern = root .. string.rep('/*', depth) .. '/.wezterm.lua'
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
  if not cmd then return end
  if type(cmd) == 'table' then
    for _, c in ipairs(cmd) do pane:send_text(c .. '\n') end
  else
    pane:send_text(cmd .. '\n')
  end
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

local function close_one(ws)
  local project = projects[ws]
  if project and project.teardown then
    wezterm.run_child_process {
      'mise', 'exec', '--cd', project.cwd, '--', 'bash', '-c', project.teardown,
    }
  end
  kill_workspace(ws)
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
      action = wezterm.action_callback(function(_win, _p, id, _label)
        if id == 'yes' then
          close_one(ws)
        elseif id == 'all' then
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
  local seen = {}
  local choices = {}

  for _, ws in ipairs(mux.get_workspace_names()) do
    local marker = (ws == current) and '● ' or '○ '
    table.insert(choices, { label = marker .. ws, id = ws })
    seen[ws] = true
  end
  for name, _ in pairs(projects) do
    if not seen[name] then
      table.insert(choices, { label = '  ' .. name .. '  (launch)', id = name })
    end
  end
  table.sort(choices, function(a, b) return a.label < b.label end)

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

-- ─── Keys ────────────────────────────────────────────────────────────

config.keys = {
  { key = 'S', mods = 'CTRL|SHIFT', action = act.EmitEvent 'launch-project' },
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
