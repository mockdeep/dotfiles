# jQuery Event Replacement Guide

## Overview
Replace jQuery event shorthands (`.click()`, `.focus()`, etc.) and `.trigger()` calls with native DOM events or helper functions.

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
- `mouseenter` � `mouseover` (jQuery translates these automatically)
- `mouseleave` � `mouseout`

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

## Focus
- Replace `.trigger()` calls and event shorthands (`.click()`, `.focus()`, etc.)
- Don't replace other jQuery usage (selectors, visibility checks, etc.)
- When chained with other jQuery calls, it's acceptable to update the chain
- Create helper functions rather than indexing into jQuery objects
- Use existing helpers (`triggerEvent`, `mouseEvent`) when available
- Add new event types to `EventType` in `src/helpers/event.ts` if needed
