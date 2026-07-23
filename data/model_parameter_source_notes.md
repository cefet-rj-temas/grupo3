# Model Parameter Source Notes

These notes translate and consolidate the qualitative parameter guidance used during model design.

## Offshore Project Return

The offshore-side return depends on project investment, auction rules, installed capacity, turbine efficiency, market regulation, and public incentives. The article therefore treats `R=100` as a normalized scale rather than as a direct euro estimate.

Portuguese offshore wind investment magnitudes were checked against public offshore wind sources and are cited in the manuscript.

## Surf-Tourism Economic Baseline

The surf-tourism side is represented by a local economic baseline tied to Peniche and WSL event evidence. The current manuscript uses `I=22` as an order-of-magnitude proxy based on the WSL/ISEG economic-impact material.

Earlier notes mentioned national tourism revenue, surf-event promotion, retail activity linked to surfing, and local visitor spending as context for why surf tourism can be economically material.

## Local Impact Scenarios

The model does not estimate hydrodynamic damage directly. Instead, it represents local loss through stylized impact scenarios:

- low impact: the surf resource remains mostly functional;
- medium impact: the wave profile or user profile is materially altered;
- high impact: surf-tourism use becomes largely nonviable.

These scenarios require author confirmation because they are modelling assumptions, not measured physical impacts.

## Litigation and Compensation

The notes treat local litigation as a mobilization effort likely carried by an association or institutional representative. They also distinguish compensation to a surf association from compensation to the broader tourism economy, since the relevant economic loss may extend beyond surfers to accommodation, food services, surf schools, event organizers, and other local businesses.

The article therefore keeps compensation as a strategic parameter (`G`) rather than treating it as a settled administrative payment.

## Remaining Calibration Questions

- Confirm whether Player 2 should formally include WSL or whether WSL should be used only as an empirical reference.
- Confirm whether `P` means judicial success narrowly or broader institutional success.
- Confirm the calibration rationale for `LR=20`, `Cs=2`, and `alpha=0.1`.
