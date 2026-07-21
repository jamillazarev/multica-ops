# {{Component}} — design-system entry

One shape for every component (agent- or human-made). Conventions (naming, props
style, state names) live in `docs/design-system/CONVENTIONS.md` — follow them, don't
invent parallel ones. The curator reviews every entry.

## What it is

{{One sentence: the job this component does. When to use it — and when NOT (which
existing component covers that case instead).}}

## Anatomy

{{Parts, named: container · label · icon slot · … (a small diagram or list)}}

## Props / parameters

| Prop | Type | Default | Notes |
|---|---|---|---|
| {{name}} | {{type}} | {{default}} | {{constraint / behavior}} |

## Variants & states

- **Variants:** {{primary · secondary · ghost …}}
- **States:** {{default · hover · focus · active · disabled · loading · error — every
  state has a story/screenshot; Design QA reviews against these}}

## Tokens used

{{color.* · space.* · type.* · motion.* — tokens only, no hardcoded values}}

## Do / Don't

- ✅ {{…}}
- ❌ {{…}}

## Story / catalog link

{{Storybook story ID / template file / brand-book page}}
