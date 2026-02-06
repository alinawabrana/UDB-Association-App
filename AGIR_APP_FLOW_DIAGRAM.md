# AGIR App Flow Diagram (PDF-ready)

## How to export to PDF

- Use a Markdown-to-PDF tool that supports **Mermaid**.
- Keep page size **A4** and enable **scale to fit width** if available.

---

## High-Level AGIR Flow (End-to-End)

```mermaid
flowchart TB
  A[App Launch] --> B{Auth Token exists?}
  B -- No --> C[Welcome Screen]
  C --> D{User action}
  D -- Sign In --> E[Auth Screen: Login]
  D -- Create Account --> F[Auth Screen: Sign Up]

  E --> G[Login API]
  F --> H[Register API]

  G --> I{Login success?}
  I -- No --> E
  I -- Yes --> J[Save JWT Token\nLocal Storage]
  H --> K{Registration success?}
  K -- No --> F
  K -- Yes --> L[User proceeds to Login]
  L --> E

  J --> M[Fetch Profile / Determine Role]
  M --> N[Main App\nRole-based Navigation]
  N --> O{Role}
  
  O -- Admin --> P[Admin Dashboard / Contracts Oversight]
  O -- Agent --> Q[Agent Dashboard / Validations & Sites]
  O -- Contractor --> R[Contractor Dashboard / Daily Reports]
  O -- Agency --> S[Agency View / QA Verification]
  O -- Public --> T[Public Transparency Portal]

  %% Global modules accessible (with permissions)
  P --> U[Contracts Module]
  Q --> U
  R --> U
  S --> U
  T --> U

  P --> V[Reporting & Analytics]
  Q --> V
  T --> V

  P --> W[Supplier Database / Directory]
  Q --> W
  T --> W

  N --> X[Documents Module]
  N --> Y[Notifications Module]
  N --> Z[Chat/Messaging\nAuthenticated Users]
```

---

## High-Level AGIR Flow (Styled Version)

```mermaid
flowchart TB
  %% --- Nodes ---
  A[App Launch] --> B{Auth Token exists?}
  B -- No --> C[Welcome Screen]
  C --> D{User action}
  D -- Sign In --> E[Auth Screen: Login]
  D -- Create Account --> F[Auth Screen: Sign Up]

  E --> G[Login API]
  F --> H[Register API]
  
  G --> I{Login success?}
  I -- No --> E
  I -- Yes --> J[Save JWT Token\nLocal Storage]
  H --> K{Registration success?}
  K -- No --> F
  K -- Yes --> L[User proceeds to Login]
  L --> E

  J --> M[Fetch Profile / Determine Role]
  M --> N[Main App\nRole-based Navigation]
  N --> O{Role}

  O -- Admin --> P[Admin Dashboard / Contracts Oversight]
  O -- Agent --> Q[Agent Dashboard / Validations & Sites]
  O -- Contractor --> R[Contractor Dashboard / Daily Reports]
  O -- Agency --> S[Agency View / QA Verification]
  O -- Public --> T[Public Transparency Portal]

  %% --- Shared Modules (permissions apply) ---
  P --> U[Contracts Module]
  Q --> U
  R --> U
  S --> U
  T --> U

  P --> V[Reporting & Analytics]
  Q --> V
  T --> V

  P --> W[Supplier Database / Directory]
  Q --> W
  T --> W

  N --> X[Documents Module]
  N --> Y[Notifications Module]
  N --> Z[Chat/Messaging\nAuthenticated Users]

  %% --- Styling ---
  classDef entry fill:#F3F4F6,stroke:#111827,stroke-width:1px,color:#111827;
  classDef decision fill:#FFF7ED,stroke:#9A3412,stroke-width:1px,color:#9A3412;
  classDef auth fill:#EFF6FF,stroke:#1D4ED8,stroke-width:1px,color:#1D4ED8;
  classDef main fill:#ECFDF5,stroke:#047857,stroke-width:1px,color:#047857;
  classDef module fill:#FAFAFA,stroke:#374151,stroke-width:1px,color:#374151;

  class A entry
  class B,D,I,K,O decision
  class C,E,F,G,H,J auth
  class M,N,P,Q,R,S,T main
  class U,V,W,X,Y,Z module
```
