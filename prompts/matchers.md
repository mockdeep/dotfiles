# Adding Matcher Arguments to click_on Calls

This project requires all `click_on` calls in feature specs to include a `matcher:` argument that specifies what should appear on the page after the click action.

## Examples

### Basic Usage
```ruby
# Bad - no matcher
click_on 'Save'

# Good - with appropriate matcher
click_on 'Save', matcher: have_text('Saved successfully')
```

### Matchers for Different Scenarios

**Navigation/Page Changes:**
```ruby
click_on 'Edit', matcher: have_button('Save')
```

**Form Actions:**
```ruby
click_on 'Delete', matcher: have_no_text('Item Name')
click_on 'Add Item', matcher: have_text('Item added')
```

**Dialog/Modal Actions:**
```ruby
click_on 'Yes, delete', matcher: have_text('Item deleted')
click_on 'Cancel', matcher: have_no_css('.modal')
```

**State Changes:**
```ruby
click_on 'Toggle Option', matcher: have_checked_field('option')
click_on 'Disable', matcher: have_button('Enable')
```

## Long Matchers

For matchers that would make the line exceed 84 characters, extract to a local variable:

```ruby
# Long matcher - extract to local
matcher = have_text('This is a very long success message that would exceed the line limit')
click_on 'Save Changes', matcher: matcher

# Short matcher - inline is fine
click_on 'Save', matcher: have_text('Saved')
```

## Removing Redundant Assertions

When you add matchers, remove redundant `expect` statements that verify the same thing:

```ruby
# Before - redundant
click_on 'Delete', matcher: have_no_text('Item')
expect(page).not_to have_text('Item')  # Remove this

# After - clean
click_on 'Delete', matcher: have_no_text('Item')
```

## Common Matchers

- `have_text('text')` - Text appears on page
- `have_no_text('text')` - Text disappears from page  
- `have_button('Button')` - Button becomes available
- `have_field('Field')` - Form field appears
- `have_no_css('.class')` - Element with CSS class disappears
- `have_select('select_name')` - Dropdown/select field appears
- `have_link('Link Text')` - Link becomes available
- `have_rows('row1', 'row2')` - Table rows appear in order

## Special Cases

### Already-Present Content
If the expected content is already visible, find what actually changes:

```ruby
# Bad - "Remove" is already visible
click_on 'Add Signature', matcher: have_text('Remove')

# Good - wait for form fields to appear
click_on 'Add Signature', matcher: have_text('Signature 1')
```

### Validation Errors
For validation errors that appear inline, wait for dialog elements:

```ruby
# Bad - error text might already be present
click_on 'save', matcher: have_text('Formula 3: must contain only numbers')

# Good - wait for validation dialog
click_on 'save', matcher: have_button('Cancel')
```

## Guidelines

1. **Be specific** - Choose matchers that verify the most important change after the click
2. **Verify state changes** - The matcher should confirm the action succeeded
3. **Avoid already-present content** - Don't match text that's already on the page before clicking
4. **Use negative matchers** - For delete actions, verify content disappears
5. **Extract long matchers** - Keep lines under 84 characters by using local variables
6. **No matchers with alerts** - Don't use matchers when handling JavaScript alerts
7. **Wait for UI elements** - Match buttons, forms, or CSS classes that appear after the action

## Process

1. Add matcher arguments to all `click_on` calls
2. Remove redundant assertions that duplicate matcher verification
3. Extract long matchers to local variables
4. Run tests to ensure matchers work correctly
5. Adjust matchers if tests fail due to incorrect expectations

## Debugging Failed Matchers

When tests fail due to incorrect matchers:

1. **Check if content already exists** - Look at the error message to see if the expected text/element is already present
2. **Find what actually changes** - Identify what appears, disappears, or becomes enabled after the click
4. **Wait for dialogs/modals** - Use `have_button('OK')` or `have_button('Cancel')` for confirmation dialogs
5. **Check the HTML output** - Review the HTML screenshot paths in test failures to understand page structure

### Common Fixes
- Change `have_text('existing text')` → `have_button('New Button')`
