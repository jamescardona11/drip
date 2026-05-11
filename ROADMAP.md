# Roadmap — Reactivar `drip` (v2)

> **Nota**: este roadmap fue reescrito tras hacer pull de `origin/main`. La rama venía con un refactor masivo (PR #2, `dev → main`) que **simplificó la API**: se eliminaron `DripEvent`, `DripAction`, `dispatch`, `BaseInterceptor`, `MemoryInterceptor` y todo el pipeline de eventos. Ahora `Drip` es Cubit-style (sólo `leak()`). El roadmap anterior apuntaba a la API vieja y quedó invalidado.

## Progress (branch `feat/update-drip`)

| Fase | Estado |
|---|---|
| 1. Bumps + ejemplos | ✅ done |
| 2. README + CHANGELOG | ✅ done |
| 3. Suite de tests (25 tests, 83.5% coverage) | ✅ done |
| 4. Hardening de API (dartdoc, strict-raw-types, _setState inline) | ✅ done |
| 5. CI/CD (GitHub Actions + dependabot + badges) | ✅ done |
| 6. Vida nueva (DripObserver) | ✅ done |
| 7. Release `0.1.0` | ✅ versión final + fecha en CHANGELOG; pendiente sólo el `dart pub publish` real |
| Extras — features distintivos | ✅ `ComputedDrip<S>` (derived state) + `AsyncDrip<T>` (sealed async state) |

Final state on this branch: `flutter analyze` clean, `flutter test` 43/43 passing, `dart pub publish --dry-run` 0 warnings.

## Arquitectura actual (post-pull)

```
lib/
├── drip.dart                  # barrel: exporta drip_core + widgets
└── src/
    ├── drip_core.dart         # Drip<DState> con leak/state/stateStream/close (53 líneas)
    └── widgets/
        ├── widgets.dart       # barrel: dripper + drop + dropper
        ├── dropper.dart       # Dropper<D> (provider), DripProvider, MultiProvider, ProviderError, DripProviderX
        ├── dripper.dart       # Dripper<D, DState> (builder + listener opcional, auto-create)
        ├── dripping.dart      # Dripping<D, DState> (listener-only)
        └── drop.dart          # DropWidget<D, DState, SelectedState> (selector memoizado)
```

**Dependencias**: `flutter`, `meta ^1.9.1`, `nested ^1.0.0` (para `MultiProvider`).

**Lo que ya NO existe** (antes documentado en README): `DripEvent`, `DripAction`, `BaseInterceptor`, `MemoryInterceptor`, `GenericStateChangeAction`, `ActionExecutor`, `DefaultDripLoggerMixin`, `DripListener`, `dispatch()`.

## Resumen de baseline (pre-Fase 1, post-pull)

| Área | Estado |
|---|---|
| `pubspec.yaml` | `0.0.1`, sdk `>=3.0.1 <4.0.0`, flutter `>=1.17.0` |
| `meta` | `^1.9.1` (techo real: `1.17.0` por flutter_test) |
| `flutter_lints` | `^2.0.0` (latest: `6.0.0`) |
| `nested` | `^1.0.0` |
| `README.md` | **DESACTUALIZADO**: documenta `DripActions` + `MemoryInterceptor` (clases eliminadas) |
| `CHANGELOG.md` | sólo `0.0.1` con TODO ficticio |
| `analysis_options.yaml` | sólo `include: package:flutter_lints/flutter.yaml` |
| `test/drip_test.dart` | 100% comentado |
| `example/counter_app` | adaptado a nueva API, lints menores (`avoid_print`, `super.key`, `prefer_const`) |
| `example/todo_app` | post-pull existe `drip/drip_todo.dart`, pero `views/home_view.dart:120` aún usa `primary:` (Material 2 deprecated) |
| CI | inexistente |

---

## Fase 1 — Bump moderno + alinear ejemplos (1–2 sesiones)

**Objetivo:** SDK/Flutter modernos, lints duros, ejemplos compilando limpio.

### 1.1 Paquete raíz
- [ ] `pubspec.yaml`:
  - `version: 0.0.1` → `0.1.0-dev.1`
  - `sdk: '>=3.0.1 <4.0.0'` → `'>=3.4.0 <4.0.0'`
  - `flutter: '>=1.17.0'` → `'>=3.16.0'`
  - `flutter_lints: ^2.0.0` → `^6.0.0`
  - `meta: ^1.9.1` → `^1.17.0` (techo flutter_test)
  - Añadir `topics: [state-management, stream, inherited-widget]`
  - Añadir `repository:` apuntando al GitHub

### 1.2 `analysis_options.yaml` endurecido
- [ ] Incluir reglas: `avoid_print`, `prefer_const_constructors`, `prefer_const_constructors_in_immutables`, `prefer_final_locals`, `require_trailing_commas`, `unawaited_futures`, `use_super_parameters`, `sort_child_properties_last`, `cancel_subscriptions`, `close_sinks`.
- [ ] Habilitar `strict-casts: true`. (Los otros `strict-*` se evalúan en Fase 4.)

### 1.3 Ejemplos
- [ ] `example/counter_app/pubspec.yaml`: subir SDK a `'>=3.4.0 <4.0.0'`.
- [ ] `example/counter_app/lib/`: arreglar `avoid_print` (2x), `use_super_parameters`, `prefer_const_constructors`.
- [ ] `example/todo_app/pubspec.yaml`: idem.
- [ ] `example/todo_app/lib/views/home_view.dart:120`: cambiar `primary: <color>` por `foregroundColor:` (API Material 3).
- [ ] Lints menores en todo_app: `use_super_parameters` en 3 lugares.

**Definición de done:** `flutter analyze` sin errores ni warnings en lib/ y ambos ejemplos.

---

## Fase 2 — Docs y CHANGELOG (1 sesión)

**Objetivo:** ningún usuario que llegue a pub.dev vea ejemplos de clases inexistentes.

### 2.1 README
- [ ] Borrar las secciones `## DripActions` y `#### Interceptors` (clases eliminadas).
- [ ] Sustituir por un "Mental model" claro: `Drip<S>` = estado + `leak(s)` para emitir; `Dropper<D>` = provider; `Dripper`/`Dripping`/`DropWidget` = consumidores.
- [ ] Quitar la nota "personal project, under-construction".
- [ ] Quitar el bloque `## TODO` (movido a este roadmap).
- [ ] Añadir tabla comparativa rápida vs Cubit (Bloc) y Riverpod — honesto: drip es mínimo, no compite en features.
- [ ] Snippet de `MultiProvider`/`DripProvider` (Nested-based) con 2 Drips.

### 2.2 CHANGELOG
- [ ] Entrada `## 0.1.0 - YYYY-MM-DD` con keep-a-changelog:
  - **Changed**: API simplificada a estilo Cubit (sólo `leak`, sin events ni interceptors)
  - **Added**: `MultiProvider`/`Dropper`/`DripProvider` basados en `nested`; `Dropper.of/read/watch`; widget `DropWidget` con selector memoizado para List/Map/value
  - **Removed**: `DripEvent`, `DripAction`, `dispatch`, `BaseInterceptor`, `MemoryInterceptor`, `DefaultDripLoggerMixin`, `DripListener`

### 2.3 Dartdoc en superficie pública
- [ ] `///` en `Drip`, `Dropper`, `DripProvider`, `MultiProvider`, `Dripper`, `Dripping`, `DropWidget`, `ProviderError`, `DripProviderX`, typedefs (`DBuilder`, `DListener`, `Selector`, `SBuilder`, `DCreate`).

---

## Fase 3 — Suite de tests (2–3 sesiones)

**Objetivo:** cobertura ≥ 80% sobre la API pública (mucho más pequeña que antes).

### 3.1 Borrar placeholder y crear estructura
- [ ] Borrar `test/drip_test.dart` (comentado entero).
- [ ] Estructura: `test/drip_test.dart`, `test/widgets/`.

### 3.2 Unit tests — `Drip`
- [ ] Estado inicial llega al stream al subscribirse.
- [ ] `leak(s)` emite por el stream.
- [ ] `close()` cierra el controller; `leak()` post-close emite warning y no rompe.
- [ ] `stateStream` es broadcast (varios listeners reciben).

### 3.3 Widget tests
- [ ] `Dropper`: `of/read/watch` throw `ProviderError` sin provider; recoge instancia.
- [ ] `DripProvider`: monta y expone el drip a los hijos.
- [ ] `MultiProvider`: combina dos `Dropper` y ambos drips son recuperables.
- [ ] `Dripper`: rebuild en cada nuevo state; con `create:` auto-provee; con `listener:` dispara side-effect.
- [ ] `Dripping`: listener se dispara, child no rebuilda.
- [ ] `DropWidget`: rebuild **sólo** cuando el selector cambia (test crítico). Cubrir las 3 ramas de equality: List (`listEquals`), Map (`mapEquals`), value (`!=`).

**Definición de done:** `flutter test --coverage` ≥ 80%; LCOV exportable.

---

## Fase 4 — Hardening de API (1–2 sesiones)

### 4.1 Limpieza de código encontrada al leer
- [ ] `dropper.dart:18`: `Key? key` + `: super(key: key)` → migrar a `super.key`.
- [ ] `drip_core.dart:45-47`: el `_setState` no emite por el stream (lo hace `leak` por separado). Decidir: o bien fusionar (`_setState` emite siempre), o bien marcar `_setState` como `@protected` y documentar que el caller debe llamar `_controller.add` aparte. Hoy es ambiguo.
- [ ] `drop.dart:48`: el callback `(context, state)` está mal nombrado — `DListener` ahora es `(D drip, DState state)`, el primer parámetro es el Drip. Renombrar para no engañar.
- [ ] `dropper.dart:55`: `SizedBox()` default para child requerido — considerar `assert(child != null)` o documentar mejor.

### 4.2 Generics + nullability
- [ ] Habilitar `strict-raw-types: true` y `strict-inference: true` en `analysis_options.yaml`; arreglar warnings.
- [ ] Confirmar el contrato: `Drip<DState>` con `DState` no nullable por convención (documentar; añadir `assert(initialState != null)` no aplica con strict null safety).

### 4.3 API surface
- [ ] Decidir si `DripProvider` (wrapper de un solo Dropper) aporta valor o es ruido vs `Dropper` directo. Si no aporta, deprecar.
- [ ] `@internal` (de `package:meta`) en `_DropperIW`, helpers privados.
- [ ] Habilitar `public_member_api_docs` como warning.

---

## Fase 5 — CI/CD (1 sesión)

- [ ] `.github/workflows/ci.yml`: format check + analyze + test + `dart pub publish --dry-run`. Matriz Flutter stable + beta.
- [ ] Badge CI en README.
- [ ] (Opcional) Codecov + badge.
- [ ] `.github/dependabot.yml` para dev_dependencies y workflows.

---

## Fase 6 — "Vida nueva": features opcionales

Priorizar **1–2 antes del release**, el resto post-`0.1.0`.

Candidatos:
1. **`DripObserver` global** — hook para logging/analytics de TODOS los drips. Rellena el hueco del eliminado `DefaultDripLoggerMixin`.
2. **`AsyncDrip<T>`** — variante con `AsyncValue` (idle/loading/data/error) para casos comunes.
3. **DevTools extension** — `package:devtools_extensions` para inspeccionar streams.
4. **`equatable_drip`** — helper opcional para comparar states sin override manual.
5. **Reintroducir interceptors como opt-in mixin** — `Drip` queda mínimo, `InterceptableDrip<S>` extiende con el pipeline. Recupera el feature perdido sin re-complicar el caso 80%.
6. **Hooks API** — `useDrip()` para `flutter_hooks`.
7. **Persistencia opcional** — `HydratedDrip<S>` con storage.

---

## Fase 7 — Release `0.1.0`

- [ ] `dart pub publish --dry-run` cero warnings.
- [ ] Score pub.dev objetivo: ≥ 130/160.
- [ ] Tag `v0.1.0`; GitHub Release con CHANGELOG.
- [ ] `dart pub publish`.

---

## Camino crítico recomendado

`Fase 1 → 2 → 5 → 3 → 4 → 7`. (Fase 6 se intercala.)

- Fase 1 (bumps + ejemplos) primero para tener base verde.
- Fase 2 (docs/CHANGELOG) inmediatamente después: **la doc obsoleta es el bug más visible para usuarios**, prioridad alta aunque sea "sólo markdown".
- Fase 5 (CI) antes que tests para que cada test escrito ya quede blindado.
- Fase 3 (tests) cubre la API real, mucho más compacta que antes.
- Fase 4 (hardening) ya con tests para validar refactors.
- Fase 7 (release).

## Estimación total

| Fase | Sesiones | Riesgo |
|---|---|---|
| 1. Bumps + ejemplos | 1–2 | bajo |
| 2. Docs/CHANGELOG | 1 | bajo |
| 3. Tests | 2–3 | medio |
| 4. Hardening | 1–2 | bajo |
| 5. CI | 1 | bajo |
| 6. Features (1–2) | 1–3 | variable |
| 7. Release | 1 | bajo |
| **Total** | **8–12 sesiones** | — |
