# jQuery Replacement Guide

## Overview
Replace jQuery methods with native DOM APIs and helper functions. This includes event shorthands (`.click()`, `.focus()`, etc.), `.trigger()` calls, `.val()` property access, and event binding methods like `.on()`.

## Patterns

### Simple Click Events
Replace with native DOM click:
```typescript
// Before (trigger)
$element.trigger('click');

// Before (event shorthand)
$element.click();

// After
element().click();
```

### Events with Properties (using triggerEvent helper)
For events that need custom properties, use the `triggerEvent` helper:
```typescript
// Before
$element.trigger('change');

// After
import { triggerEvent } from 'src/helpers/event';
triggerEvent(element(), 'change');
```

### Mouse Events with Coordinates
Use the `mouseEvent` helper from `_support/events.ts`:
```typescript
// Before
$element.trigger($.Event('mousemove', { pageX: 120, pageY: 510 }));

// After
import { mouseEvent } from '_support/events';
element().dispatchEvent(mouseEvent('mousemove', { pageX: 120, pageY: 510 }));
```

### Events with Detail Properties
Use triggerEvent with detail parameter:
```typescript
// Before
$element.trigger($.Event('keyup', { key: 'Enter' }));

// After
triggerEvent(element(), 'keyup', { key: 'Enter' });
```

### Event Type Mappings
- `mouseenter` → `mouseover` (jQuery translates these automatically)
- `mouseleave` → `mouseout`

### Value Access (.val() replacement)
Replace jQuery `.val()` calls with native `.value` property:
```typescript
// Before (getting value)
const value = $input.val();

// Before (setting value)
$input.val('new value');

// After (getting value)
const value = inputElement().value;

// After (setting value)
inputElement().value = 'new value';
```

### Event Binding (.on() replacement)
Replace jQuery `.on()` with native `addEventListener`:
```typescript
// Before
$form.on('submit', (event) => {
  return false;
});

// After
formElement().addEventListener('submit', (event) => {
  event.preventDefault();
  return false;
});
```

### Class Checking (.hasClass() replacement)
Replace jQuery `.hasClass()` with native `classList` or test matchers:
```typescript
// Before
expect($element.hasClass('locked')).toBe(false);

// After
expect(element()).not.toHaveClass('locked');
```

### Element Count and Descendant Checks
Use `toHaveDescendants` matcher instead of checking `.length`:
```typescript
// Before
expect($('.tooltip--error')).toHaveLength(1);
expect($('.tooltip--error')).toHaveLength(0);

// After
expect(document.body).toHaveDescendants('.tooltip--error', 1);
expect(document.body).not.toHaveDescendants('.tooltip--error');
```

### DOM Manipulation
Replace jQuery DOM manipulation with native methods:
```typescript
// Before (append)
$('body').append(element1, element2);

// After (append)
document.body.appendChild(element1);
document.body.appendChild(element2);

// Before (remove)
$('#my-element').remove();

// After (remove)
document.getElementById('my-element')?.remove();
```

### Element Creation and Setup
Replace jQuery element creation with native DOM APIs:
```typescript
// Before
$('head').append("<meta name='csrf-token' content='token123'>");

// After
const metaTag = document.createElement('meta');
metaTag.name = 'csrf-token';
metaTag.content = 'token123';
document.head.appendChild(metaTag);
```

## Helper Functions
Create helper functions using `findEl`/`findEls` for commonly accessed elements:
```typescript
function reviewerColumn(): HTMLElement {
  return findEls(element(), 'div', '.reviewer-column', { count: 3 })[0];
}

function nextButton(): HTMLElement {
  return findEl(element(), 'button', '.next-btn');
}

// Usage
reviewerColumn().click();
nextButton().click();
```

## Best Practices for Spec Files

### Replace jQuery Event Shorthands
- Avoid using `$element.click()`, `$element.focus()`, etc.
- Instead, create helper functions that return HTMLElement
- Use native DOM methods on the returned elements

### Replace jQuery Value Access
- Avoid using `$element.val()` for getting/setting values
- Use `.value` property on HTMLInputElement/HTMLTextAreaElement
- Create typed helper functions that return the correct element type

Example helper functions for form elements:
```typescript
function nameField(): HTMLInputElement {
  return findEl(element(), 'input', '.name');
}

function csvField(): HTMLTextAreaElement {
return findEl(element(), 'input', '.csv-field');
}

// Usage
nameField().value = 'John Doe';
expect(csvField().value).toMatch(/expected content/);
```

### Multiple Elements
For collections of elements that need individual access:
```typescript
function entryRemoveButtons(): HTMLElement[] {
  return findEls(element(), 'button', '.entry-remove', { count: 3 });
}

// Usage
entryRemoveButtons()[0].click(); // First button
entryRemoveButtons().forEach(button => button.click()); // All buttons
```

### Avoid jQuery Object Indexing
Don't use `$element[0].click()` - create proper helper functions instead:
```typescript
// Bad
$('.my-button')[0].click();

// Good
function myButton(): HTMLElement {
  return findEl(element(), 'button', '.my-button');
}
myButton().click();
```

### Cleaning Up Unused jQuery Variables
Remove jQuery variables when they're no longer needed:
```typescript
// Before
let $element: JQuery;
let $button: JQuery;

beforeEach(() => {
  $element = $(element());
  $button = $element.find('.my-button');
});

// After
// Remove unused variables and use helper functions directly
function myButton(): HTMLElement {
  return findEl(element(), 'button', '.my-button');
}
```

## Migration Focus Areas

### Priority Replacements
1. **Event shorthands**: `.click()`, `.focus()`, `.blur()`, `.change()`, etc.
2. **Value access**: `.val()` calls (both getting and setting)
3. **Event binding**: `.on()` method calls
4. **Event triggering**: `.trigger()` calls
5. **Class checking**: `.hasClass()` calls
6. **Element counting**: `.length` checks for element counts
7. **DOM manipulation**: `.append()`, `.remove()` calls
8. **jQuery object indexing**: `$element[0]` patterns

### What NOT to Replace (Yet)
- jQuery selectors and DOM traversal methods
- Visibility checks (`.toBeVisible()`, etc.)
- Other jQuery utilities that don't have direct native equivalents
- Complex jQuery chains unless they contain the priority methods above

### Implementation Guidelines
- Create helper functions rather than indexing into jQuery objects (`$element[0]`)
- Use existing helpers (`triggerEvent`, `mouseEvent`) when available
- Add new event types to `EventType` in `src/helpers/event.ts` if needed
- Always verify tests pass after replacements

### Common Patterns Learned
- Helper functions improve maintainability and readability
- Batching similar replacements in the same file is more efficient
- Use `toHaveDescendants` matcher instead of checking `.length` on jQuery objects
- Leverage existing helper functions rather than creating new ones when possible
- Clean up unused jQuery variables after replacement
- Native DOM methods often require more explicit steps but provide better type safety
- `toHaveDescendants` with zero count uses `.not.toHaveDescendants()` pattern
