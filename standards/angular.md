# Angular

## Overview

Standards for Angular applications (TypeScript). For non-Angular-specific
TypeScript conventions, see `typescript.md` - this file covers only what is
specific to Angular.

The baseline is the **official Angular Style Guide** (angular.dev),
maintained directly by the Angular team as part of the official docs:
https://angular.dev/style-guide

This file defines only the rules that differ from or extend that baseline.
When in doubt, the official Angular Style Guide is the authority.

**Version note:** Angular's official guidance has evolved significantly in
recent versions - standalone components, signals, and (from v20+) dropping
the `.component` suffix from generated file names. Target **current**
Angular conventions (the ones the Angular CLI's scaffolding produces by
default today), not the older, now-superseded John Papa Angular Style Guide
written for AngularJS/early Angular 2+. If a project pins an older Angular
major version, confirm which convention generation applies before assuming
the latest guidance.

---

## Rules That Override the Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match the Baseline (Key Reminders)

These rules are highlighted because they are commonly missed:

### Standalone Components

New components are standalone by default (no `NgModule` required) unless
the project has an established reason to keep using `NgModule`-based
architecture:

```typescript
// good - standalone, no NgModule needed
@Component({
  selector: 'app-order-summary',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './order-summary.component.html',
})
export class OrderSummaryComponent { }
```

### File Naming and Structure

Files follow the current Angular CLI convention -
`feature.component.ts`/`.html`/`.spec.ts` grouped together, or the v20+
suffix-free convention if the project has adopted it. Match whichever
convention the rest of the project already uses consistently.

### Folder Structure - Feature Modules vs. Shared/Core

Organize by feature, not by file type:

```
// bad - grouped by file type, features scattered across top-level folders
src/app/components/
src/app/services/
src/app/pipes/

// good - grouped by feature
src/app/features/orders/
  order-summary.component.ts
  order.service.ts
src/app/shared/
  (cross-feature reusable components/pipes)
src/app/core/
  (singleton services, app-wide config)
```

### The LIFT Principle

Structure files so they are easy to **L**ocate, **I**dentify at a glance,
kept **F**lat where possible (avoid deep nesting for its own sake), and
**T**ry to be DRY without sacrificing the first three:

```
// bad - deeply nested for no structural reason
src/app/features/orders/components/summary/order-summary.component.ts

// good - flat, locatable, identifiable
src/app/features/orders/order-summary.component.ts
```

### Signals for State

Prefer signals (`signal()`, `computed()`, `effect()`) for component-local
reactive state over manually-managed `BehaviorSubject`s, in projects
targeting current Angular versions:

```typescript
// good - modern signal-based state
export class OrderSummaryComponent {
  orders = signal<Order[]>([]);
  total = computed(() =>
    this.orders().reduce((sum, o) => sum + o.total, 0)
  );
}
```

### Single Responsibility Per File

One component, directive, service, or pipe per file - never combine
multiple Angular building blocks in one file:

```typescript
// bad - two components in one file
@Component({ selector: 'app-order-summary', ... })
export class OrderSummaryComponent { }

@Component({ selector: 'app-order-detail', ... })
export class OrderDetailComponent { }

// good - split into order-summary.component.ts and order-detail.component.ts
```

### Selector Prefixes

Use a consistent, project-specific selector prefix for components and
directives (e.g. `app-`) to avoid collisions with native elements or
third-party libraries:

```typescript
// good
@Component({ selector: 'app-order-summary', ... })
@Directive({ selector: '[appHighlight]' })
```

### Dependency Injection

Prefer the `inject()` function over constructor injection in new code
targeting current Angular versions - it composes better with signal-based
patterns and standalone APIs:

```typescript
// good - modern
export class OrderService {
  private http = inject(HttpClient);
}

// acceptable - constructor injection, still valid, use if the project
// already uses it consistently
export class OrderService {
  constructor(private http: HttpClient) { }
}
```

---

## What Claude Must Not Do

- Do not create a new `NgModule`-based component unless the project has an
  established reason to avoid standalone components
- Do not combine multiple components/directives/services/pipes in one file
- Do not organize new files by type (`components/`, `services/`) instead of
  by feature
- Do not apply the older AngularJS-era John Papa style guide's conventions
  to a current-version Angular project
- Do not nest folders deeper than the LIFT principle's "flat" guidance
  justifies
