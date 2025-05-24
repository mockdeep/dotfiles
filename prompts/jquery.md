# jQuery Trigger Replacement Guide

## Overview
Replace jQuery `.trigger()` calls with native DOM events or helper functions.

## Patterns

### Simple Click Events
Replace with native DOM click:
```typescript
// Before
$element.trigger('click');

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
- `mouseenter` ’ `mouseover` (jQuery translates these automatically)
- `mouseleave` ’ `mouseout`

## Helper Functions
Create helper functions using `findEl`/`findEls` for commonly accessed elements:
```typescript
function reviewerColumn(): HTMLElement {
  return findEls(element(), 'div', '.reviewer-column', { count: 3 })[0];
}

// Usage
reviewerColumn().click();
```

## Focus
- Only replace `.trigger()` calls, not all jQuery usage
- When chained with other jQuery calls, it's acceptable to update the chain
- Standalone jQuery usage should remain unchanged
- Use existing helpers (`triggerEvent`, `mouseEvent`) when available
- Add new event types to `EventType` in `src/helpers/event.ts` if needed
