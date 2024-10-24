# Interface Specifications GFModules

## Disclaimer

This project and all associated code serve solely as **documentation and demonstration purposes**
to illustrate potential system communication patterns and architectures.

This codebase:

- Is NOT intended for production use
- Does NOT represent a final specification
- Should NOT be considered feature-complete or secure
- May contain errors, omissions, or oversimplified implementations
- Has NOT been tested or hardened for real-world scenarios

The code examples are *only* meant to help understand concepts and demonstrate possibilities.

By using or referencing this code, you acknowledge that you do so at your own risk and that
the authors assume no liability for any consequences of its use.

## Context

The GFModules project is a collection of applications that have the purpose of improving
data exchange between healthcare providers. This project is the technical implementation of
various components of the 'Generieke Functies, lokalisatie en addressering' project from the
Ministry of Health, Welfare and Sport of the Dutch government.

<div style="page-break-after: always;"></div>

## Interfaces

In this coordination repository there are a few interfaces definitions which need to be implemented by (some of) the
market healthcare provider parties.

- [Fetch metadata](fetch-metadata.md)
- [Find endpoints](find-endpoints.md)
