# Agir - UI/UX Design Specification
## Application for Intelligent Resource Management

---

## Table of Contents

1. [Design Overview](#design-overview)
2. [Screen Classification](#screen-classification)
3. [Screens That Remain](#screens-that-remain)
4. [Screens Requiring Modification](#screens-requiring-modification)
5. [Screens to Remove](#screens-to-remove)
6. [New Screens to Implement](#new-screens-to-implement)
7. [Role-Based UI Differences](#role-based-ui-differences)
8. [Screen Flow Diagrams](#screen-flow-diagrams)
9. [Design Guidelines](#design-guidelines)

---

## Design Overview

### Design Philosophy

**Agir** maintains the core design language of UDB Association while adapting it for government use:

- **Professional & Trustworthy**: Government-appropriate color scheme and typography
- **Clear Hierarchy**: Role-based navigation and information architecture
- **Transparency**: Public-facing views emphasize clarity and accessibility
- **Efficiency**: Streamlined workflows for daily operations
- **Security**: Visual indicators of secure, validated information

### Color Scheme Adaptation

**Base Colors (Similar to UDB):**
- **Primary Green**: Dark olive green (trust, government)
- **Secondary Blue**: Professional blue (information, data)
- **Accent Orange**: Warning/attention (validation pending)
- **Success Green**: Approved/validated status
- **Background**: Light gray/white (clean, professional)

**Status Colors:**
- **Draft**: Gray
- **Active**: Blue
- **In Progress**: Orange
- **Pending Validation**: Yellow
- **Approved**: Green
- **Rejected**: Red
- **Completed**: Dark Green

---

## Screen Classification

### Category 1: Screens That Remain (Minimal Changes)
These screens keep their core functionality with minor adaptations:

1. Welcome Screen
2. Sign In Screen
3. Sign Up Screen (adapted for government users)
4. Profile Screen (adapted for civil servants)

### Category 2: Screens Requiring Modification
These screens need significant updates for government context:

1. Home Screen → Dashboard (role-based metrics)
2. Projects Screen → Internal Projects (adapted)
3. Directory Screen → Enhanced with suppliers/vendors
4. Organes Screen → Government Structure (major adaptation)
5. News Screen → Optional (may be removed or adapted)

### Category 3: Screens to Remove
These screens are not needed for the government app:

1. Event Screen (Calendar) - Remove entirely
2. Shop Screen (E-commerce) - Remove entirely

### Category 4: New Screens to Implement
These are completely new screens for Agir:

1. Contracts List Screen
2. Contract Detail Screen
3. Contract Creation Screen
4. Daily Report Submission Screen
5. Daily Report Validation Screen
6. Field Verification Screen
7. Reporting Dashboard Screen
8. Map View Screen
9. Supplier Directory Screen
10. Contract Timeline Screen

---

## Screens That Remain

### 1. Welcome Screen

**Status:** Minimal Changes Required

**Changes:**
- Update branding from "UDB Association" to "Agir"
- Update tagline to reflect government focus
- Maintain same layout and structure

**UI Elements:**
```
┌─────────────────────────────────────┐
│         [Agir Logo]                 │
│                                     │
│    Welcome to Agir                  │
│    Intelligent Resource Management   │
│                                     │
│  Connect, manage, and monitor       │
│  public resources efficiently       │
│                                     │
│  ┌─────────────────────────────┐   │
│  │   Sign In                    │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │   Create Account            │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

---

### 2. Sign In Screen

**Status:** Minimal Changes Required

**Changes:**
- Update app name to "Agir"
- Maintain same form structure
- Role selection may be added (if multiple roles per user)

**UI Elements:**
- Same as UDB Association
- Email/Password fields
- Remember me checkbox
- Forgot password link

---

### 3. Sign Up Screen

**Status:** Moderate Changes Required

**Changes:**
- Remove "Member" terminology
- Add "Civil Servant" or "Government Employee" fields
- Add organization/department field
- Add role selection (if applicable)
- Remove association-specific fields

**New Fields:**
- Organization/Department
- Employee ID
- Position/Title
- Role (Agent/Admin/Public)

---

### 4. Profile Screen

**Status:** Moderate Changes Required

**Changes:**
- Update terminology (no "Member ID", use "Employee ID" or "User ID")
- Add role-specific information
- Add organization/department display
- Remove association-specific features

**UI Elements:**
- Profile picture
- Name and title
- Organization/Department
- Employee ID
- Role badge
- Contact information
- Settings options

---

## Screens Requiring Modification

### 1. Home Screen → Dashboard

**Status:** Major Modification Required

**Original:** UDB Association Home Screen  
**New:** Role-Based Dashboard

**Changes:**
- Remove association-specific content
- Add role-based metrics and widgets
- Add contract overview (for relevant roles)
- Add pending validations (for agents)
- Add daily reports (for contractors)

**Dashboard Variations by Role:**

#### Admin Dashboard:
```
┌─────────────────────────────────────┐
│  ☰ Menu    Admin Dashboard          │
│                                     │
│  Key Metrics                        │
│  ┌──────┐ ┌──────┐ ┌──────┐       │
│  │Total │ │Active│ │Spent │       │
│  │Cont. │ │Sites │ │Amount│       │
│  │ 125  │ │  45  │ │$2.5B │       │
│  └──────┘ └──────┘ └──────┘       │
│                                     │
│  Quick Actions                      │
│  ┌─────────────────────────────┐   │
│  │ + Create New Contract      │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ View All Contracts            │   │
│  └─────────────────────────────┘   │
│                                     │
│  Recent Contracts                   │
│  ┌─────────────────────────────┐   │
│  │ Road Construction Project   │   │
│  │ $20B  In Progress 45%      │   │
│  └─────────────────────────────┘   │
│                                     │
│  Pending Validations                │
│  ┌─────────────────────────────┐   │
│  │ 5 reports awaiting review   │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

#### Agent Dashboard:
```
┌─────────────────────────────────────┐
│  ☰ Menu    Agent Dashboard           │
│                                     │
│  My Assigned Contracts               │
│  ┌─────────────────────────────┐   │
│  │ Road Project A              │   │
│  │ Progress: 45%                │   │
│  │ Last Report: Today           │   │
│  └─────────────────────────────┘   │
│                                     │
│  Pending Validations               │
│  ┌─────────────────────────────┐   │
│  │ 3 Daily Reports              │   │
│  │ Awaiting Validation          │   │
│  └─────────────────────────────┘   │
│                                     │
│  Quick Actions                      │
│  ┌─────────────────────────────┐   │
│  │ Field Verification          │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

#### Contractor Dashboard:
```
┌─────────────────────────────────────┐
│  ☰ Menu    Contractor Dashboard     │
│                                     │
│  My Active Contracts                │
│  ┌─────────────────────────────┐   │
│  │ Road Construction Project   │   │
│  │ $20B  Progress: 45%         │   │
│  │ Next Report Due: Today      │   │
│  └─────────────────────────────┘   │
│                                     │
│  Daily Reports                      │
│  ┌─────────────────────────────┐   │
│  │ + Submit Daily Report       │   │
│  └─────────────────────────────┘   │
│                                     │
│  Recent Reports                     │
│  ┌─────────────────────────────┐   │
│  │ Today - Pending Validation  │   │
│  │ Yesterday - Approved ✓      │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

#### Public Dashboard:
```
┌─────────────────────────────────────┐
│  ☰ Menu    Public Portal             │
│                                     │
│  Public Contracts Overview           │
│  ┌─────────────────────────────┐   │
│  │ Total Contracts: 125        │   │
│  │ In Progress: 45             │   │
│  │ Completed: 80               │   │
│  └─────────────────────────────┘   │
│                                     │
│  Recent Updates                     │
│  ┌─────────────────────────────┐   │
│  │ Road Project - 45% Complete │   │
│  │ Validated: Today            │   │
│  └─────────────────────────────┘   │
│                                     │
│  View Map                          │
│                                     │
└─────────────────────────────────────┘
```

---

### 2. Projects Screen → Internal Projects

**Status:** Moderate Modification Required

**Changes:**
- Keep core project management functionality
- Adapt for internal administration projects
- Remove association-specific features
- Add internal team collaboration
- Focus on internal works only

**UI Elements:**
- Project list (internal only)
- Project status cards
- Task assignment
- Team members
- Progress tracking
- Internal documents

---

### 3. Directory Screen → Enhanced Directory

**Status:** Major Modification Required

**Changes:**
- Add "Suppliers" section (Contractors & Agencies)
- Keep "Agents" section
- Add "Organizations" section
- Enhanced search and filtering
- Performance ratings for suppliers

**New Sections:**
1. **Suppliers**
   - Contractors
   - Agencies
   - Search and filter
   - Performance ratings

2. **Agents**
   - Monitoring agents
   - Contact information
   - Assigned contracts

3. **Organizations**
   - Government departments
   - Agencies
   - Contact information

---

### 4. Organes Screen → Government Structure

**Status:** Major Modification Required

**Original:** UDB Association divisions and branches  
**New:** Government administration structure

**Changes:**
- Replace association structure with government hierarchy
- Update from "UDB branches" to "Government departments"
- Replace "Association members" with "Civil servants"
- Adapt for government organizational structure
- Remove association-specific features

**UI Elements:**
- Government departments list
- Agencies list
- Organizational hierarchy view
- Department details
- Civil servants directory (by department)
- Contact information by department

**UI Layout:**
```
┌─────────────────────────────────────┐
│  ☰ Menu    Government Structure     │
│                                     │
│  [Search] [Filter]                  │
│                                     │
│  Departments                        │
│  ┌─────────────────────────────┐   │
│  │ Public Works Department     │   │
│  │ [View Details]              │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Infrastructure Department   │   │
│  │ [View Details]              │   │
│  └─────────────────────────────┘   │
│                                     │
│  Agencies                           │
│  ┌─────────────────────────────┐   │
│  │ Quality Control Agency      │   │
│  │ [View Details]              │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

---

### 5. News Screen

**Status:** Optional - May Be Removed or Adapted

**Decision Required:**
- Keep for announcements?
- Remove entirely?
- Adapt for contract announcements?

**If Kept:**
- Government announcements
- Contract awards
- Public notices
- System updates

---

## Screens to Remove

### 1. Event Screen (Calendar)

**Status:** Remove Entirely

**Reason:** Not needed for government procurement management

**Action:**
- Remove from navigation
- Remove from codebase
- No replacement needed

**Original Functionality:**
- Association events calendar
- Event registration
- Event details

---

### 2. Shop Screen

**Status:** Remove Entirely

**Reason:** E-commerce functionality not part of government app

**Action:**
- Remove from navigation
- Remove from codebase
- No replacement needed

**Original Functionality:**
- Product catalog
- Shopping cart
- Order management

---

## New Screens to Implement

### 1. Contracts List Screen

**Purpose:** Display all contracts with filtering and search

**UI Layout:**
```
┌─────────────────────────────────────┐
│  ☰ Menu    Contracts                 │
│                                     │
│  [Search] [Filter] [+ New]          │
│                                     │
│  Filter: [All] [Active] [Completed]  │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Road Construction Project   │   │
│  │ $20,000,000,000             │   │
│  │ Status: In Progress          │   │
│  │ Progress: 45%                │   │
│  │ Location: [Map Pin] Libreville│   │
│  │ Contractor: ABC Construction │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Bridge Construction          │   │
│  │ $5,000,000,000               │   │
│  │ Status: Active               │   │
│  │ Progress: 12%                │   │
│  │ Location: [Map Pin] Port-Gentil│   │
│  │ Contractor: XYZ Builders     │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Load More]                         │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- Search contracts
- Filter by status, contractor, location
- Sort options
- Map view toggle
- Contract cards with key information
- Progress indicators
- Status badges

---

### 2. Contract Detail Screen

**Purpose:** Comprehensive contract information view

**UI Layout:**
```
┌─────────────────────────────────────┐
│  ← Back    Contract Details          │
│                                     │
│  Road Construction Project          │
│  Contract ID: CNT-2025-001          │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Status: In Progress          │   │
│  │ Progress: 45%                │   │
│  │ Amount: $20,000,000,000       │   │
│  │ Start: Jan 1, 2025          │   │
│  │ End: Dec 31, 2025           │   │
│  └─────────────────────────────┘   │
│                                     │
│  Location                           │
│  ┌─────────────────────────────┐   │
│  │ [Map View]                  │   │
│  │ Libreville, Gabon           │   │
│  └─────────────────────────────┘   │
│                                     │
│  Assigned To                        │
│  • Contractor: ABC Construction     │
│  • Agent: John Doe                  │
│  • Agency: Quality Experts Ltd      │
│                                     │
│  Budget Breakdown                   │
│  ┌─────────────────────────────┐   │
│  │ Materials: $10B              │   │
│  │ Labor: $5B                  │   │
│  │ Equipment: $3B               │   │
│  │ Other: $2B                   │   │
│  └─────────────────────────────┘   │
│                                     │
│  Daily Reports                      │
│  ┌─────────────────────────────┐   │
│  │ Today - Pending            │   │
│  │ Yesterday - Approved ✓     │   │
│  │ [View All Reports]         │   │
│  └─────────────────────────────┘   │
│                                     │
│  Documents                          │
│  ┌─────────────────────────────┐   │
│  │ Contract Document.pdf      │   │
│  │ Technical Specs.pdf         │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Actions Menu]                     │
│                                     │
└─────────────────────────────────────┘
```

**Role-Specific Actions:**
- **Admin:** Edit, Assign, Manage
- **Contractor:** Submit Report, View Details
- **Agent:** Validate Reports, Field Verification
- **Public:** View Only (validated information)

---

### 3. Contract Creation Screen

**Purpose:** Create new public procurement contracts (Admin only)

**UI Layout:**
```
┌─────────────────────────────────────┐
│  ← Back    Create Contract           │
│                                     │
│  Contract Information                │
│  ┌─────────────────────────────┐   │
│  │ Contract Title *            │   │
│  │ [Road Construction Project]  │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Description *                │   │
│  │ [Multi-line text area]       │   │
│  └─────────────────────────────┘   │
│                                     │
│  Financial Information              │
│  ┌─────────────────────────────┐   │
│  │ Contract Amount *           │   │
│  │ [$20,000,000,000]           │   │
│  └─────────────────────────────┘   │
│                                     │
│  Dates                              │
│  ┌─────────────────────────────┐   │
│  │ Start Date * [Calendar]    │   │
│  │ End Date * [Calendar]       │   │
│  └─────────────────────────────┘   │
│                                     │
│  Location                           │
│  ┌─────────────────────────────┐   │
│  │ [Map Picker]               │   │
│  │ Select location on map    │   │
│  └─────────────────────────────┘   │
│                                     │
│  Assignments                        │
│  ┌─────────────────────────────┐   │
│  │ Contractor * [Dropdown]     │   │
│  │ Monitoring Agent(s) *        │   │
│  │ [Multi-select]               │   │
│  │ Agency (Optional)            │   │
│  │ [Dropdown]                   │   │
│  └─────────────────────────────┘   │
│                                     │
│  Budget Breakdown                   │
│  ┌─────────────────────────────┐   │
│  │ + Add Budget Item           │   │
│  │ Item 1: Materials - $10B   │   │
│  │ Item 2: Labor - $5B         │   │
│  └─────────────────────────────┘   │
│                                     │
│  Documents                          │
│  ┌─────────────────────────────┐   │
│  │ + Upload Contract Document  │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │      Create Contract        │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- Form validation
- Map location picker
- Multi-select for agents
- Budget item management
- Document upload
- Auto-calculation of totals

---

### 4. Daily Report Submission Screen

**Purpose:** Contractors submit daily progress reports

**UI Layout:**
```
┌─────────────────────────────────────┐
│  ← Back    Submit Daily Report       │
│                                     │
│  Contract: Road Construction        │
│  Date: January 15, 2025             │
│                                     │
│  Progress                            │
│  ┌─────────────────────────────┐   │
│  │ Overall Progress: [45%]     │   │
│  │ [Progress Slider]              │   │
│  └─────────────────────────────┘   │
│                                     │
│  Work Completed Today                │
│  ┌─────────────────────────────┐   │
│  │ [Text Area]                  │   │
│  │ Describe work completed...   │   │
│  └─────────────────────────────┘   │
│                                     │
│  Images (Required)                   │
│  ┌─────────────────────────────┐   │
│  │ [Image 1] [Image 2] [Image 3]│   │
│  │ + Add Image                  │   │
│  └─────────────────────────────┘   │
│                                     │
│  Videos (Optional)                  │
│  ┌─────────────────────────────┐   │
│  │ [Video 1] [Video 2]          │   │
│  │ + Add Video                  │   │
│  └─────────────────────────────┘   │
│                                     │
│  Comments/Notes                      │
│  ┌─────────────────────────────┐   │
│  │ [Text Area]                  │   │
│  │ Any additional notes...      │   │
│  └─────────────────────────────┘   │
│                                     │
│  Issues/Challenges (Optional)        │
│  ┌─────────────────────────────┐   │
│  │ [Text Area]                  │   │
│  │ Report any issues...         │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │      Submit Report           │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- Progress percentage input
- Rich text editor for description
- Multiple image upload
- Video upload support
- Image/video preview
- Form validation
- Draft save functionality

---

### 5. Daily Report Validation Screen

**Purpose:** Agents review and validate contractor reports

**UI Layout:**
```
┌─────────────────────────────────────┐
│  ← Back    Validate Report           │
│                                     │
│  Contract: Road Construction        │
│  Report Date: January 15, 2025      │
│  Submitted By: ABC Construction     │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Status: Pending Validation  │   │
│  └─────────────────────────────┘   │
│                                     │
│  Progress Reported: 45%             │
│                                     │
│  Work Description                   │
│  ┌─────────────────────────────┐   │
│  │ [Contractor's description]   │   │
│  └─────────────────────────────┘   │
│                                     │
│  Images Submitted                   │
│  ┌─────────────────────────────┐   │
│  │ [Gallery View]               │   │
│  │ [Image 1] [Image 2] [Image 3]│   │
│  │ Tap to view full size        │   │
│  └─────────────────────────────┘   │
│                                     │
│  Videos Submitted                   │
│  ┌─────────────────────────────┐   │
│  │ [Video 1] [Video 2]          │   │
│  │ Tap to play                  │   │
│  └─────────────────────────────┘   │
│                                     │
│  Field Verification                 │
│  ┌─────────────────────────────┐   │
│  │ [ ] Perform Field Check      │   │
│  │ [ ] Verified on Site         │   │
│  └─────────────────────────────┘   │
│                                     │
│  Verification Comments              │
│  ┌─────────────────────────────┐   │
│  │ [Text Area]                  │   │
│  │ Add verification notes...    │   │
│  └─────────────────────────────┘   │
│                                     │
│  Verification Media                 │
│  ┌─────────────────────────────┐   │
│  │ + Add Verification Photos    │   │
│  └─────────────────────────────┘   │
│                                     │
│  Validation Decision                │
│  ┌─────────────────────────────┐   │
│  │ [Approve] [Reject]           │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- View contractor submission
- Media gallery viewer
- Video player
- Field verification checklist
- Verification comment section
- Verification media upload
- Approve/Reject actions
- Rejection reason (if rejected)

---

### 6. Field Verification Screen

**Purpose:** Agents perform on-site verification

**UI Layout:**
```
┌─────────────────────────────────────┐
│  ← Back    Field Verification        │
│                                     │
│  Contract: Road Construction        │
│  Site Location: Libreville          │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [Map View]                  │   │
│  │ Current Location            │   │
│  │ [Get Directions]            │   │
│  └─────────────────────────────┘   │
│                                     │
│  Verification Checklist              │
│  ┌─────────────────────────────┐   │
│  │ [ ] Work matches report      │   │
│  │ [ ] Progress verified        │   │
│  │ [ ] Quality standards met    │   │
│  │ [ ] Safety protocols followed│   │
│  └─────────────────────────────┘   │
│                                     │
│  Site Photos                         │
│  ┌─────────────────────────────┐   │
│  │ [Camera Icon]                │   │
│  │ + Take Verification Photo    │   │
│  └─────────────────────────────┘   │
│                                     │
│  Site Video                          │
│  ┌─────────────────────────────┐   │
│  │ [Video Icon]                 │   │
│  │ + Record Verification Video  │   │
│  └─────────────────────────────┘   │
│                                     │
│  Verification Notes                 │
│  ┌─────────────────────────────┐   │
│  │ [Text Area]                  │   │
│  │ Document findings...        │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │      Complete Verification   │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- GPS location capture
- Map integration with directions
- Camera integration
- Video recording
- Verification checklist
- Notes and documentation
- Offline capability (sync later)

---

### 7. Reporting Dashboard Screen

**Purpose:** Comprehensive analytics and reporting

**UI Layout:**
```
┌─────────────────────────────────────┐
│  ☰ Menu    Reports & Analytics       │
│                                     │
│  Key Metrics                         │
│  ┌─────────────────────────────┐   │
│  │ Total Contracts: 125         │   │
│  │ In Progress: 45               │   │
│  │ Completed: 80                 │   │
│  │ Total Spending: $2.5B         │   │
│  │ Active Contractors: 32       │   │
│  └─────────────────────────────┘   │
│                                     │
│  Contract Status                    │
│  ┌─────────────────────────────┐   │
│  │ [Pie Chart]                  │   │
│  │ Active | In Progress | Done │   │
│  └─────────────────────────────┘   │
│                                     │
│  Spending Over Time                 │
│  ┌─────────────────────────────┐   │
│  │ [Line Chart]                 │   │
│  │ Monthly spending trend       │   │
│  └─────────────────────────────┘   │
│                                     │
│  Progress by Contract               │
│  ┌─────────────────────────────┐   │
│  │ [Bar Chart]                  │   │
│  │ Contract progress bars       │   │
│  └─────────────────────────────┘   │
│                                     │
│  Geographic Distribution            │
│  ┌─────────────────────────────┐   │
│  │ [Map View]                   │   │
│  │ Contracts by location        │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Export Report] [Generate PDF]     │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- Real-time metrics
- Interactive charts
- Map visualization
- Export options (PDF, Excel)
- Date range filters
- Custom report generation

---

### 8. Map View Screen

**Purpose:** Geographic visualization of contracts

**UI Layout:**
```
┌─────────────────────────────────────┐
│  ☰ Menu    Contract Map              │
│                                     │
│  [Filter] [List View]                │
│                                     │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │      [Interactive Map]       │   │
│  │                             │   │
│  │  [Marker 1] [Marker 2]       │   │
│  │  [Marker 3] [Cluster]        │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  Filter Options                     │
│  ┌─────────────────────────────┐   │
│  │ Status: [All ▼]              │   │
│  │ Type: [All ▼]                │   │
│  │ Region: [All ▼]              │   │
│  └─────────────────────────────┘   │
│                                     │
│  Contract Markers                   │
│  • Blue: Active                     │
│  • Orange: In Progress              │
│  • Green: Completed                 │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- Interactive map (Google Maps/Mapbox)
- Contract markers with status colors
- Cluster view for multiple contracts
- Click marker for contract details
- Filter by status, type, region
- Route planning
- Geographic search
- List view toggle

---

### 9. Supplier Directory Screen

**Purpose:** Browse contractors and agencies

**UI Layout:**
```
┌─────────────────────────────────────┐
│  ☰ Menu    Supplier Directory        │
│                                     │
│  [Search] [Filter]                  │
│                                     │
│  Filter: [All] [Contractors] [Agencies]│
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [Logo] ABC Construction      │   │
│  │ Type: Contractor             │   │
│  │ Rating: ⭐⭐⭐⭐ (4.5)        │   │
│  │ Active Contracts: 5          │   │
│  │ [View Details] [Contact]     │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [Logo] Quality Experts Ltd   │   │
│  │ Type: Agency                  │   │
│  │ Rating: ⭐⭐⭐⭐⭐ (5.0)        │   │
│  │ Active Contracts: 12         │   │
│  │ [View Details] [Contact]     │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- Search suppliers
- Filter by type (Contractor/Agency)
- Performance ratings
- Active contract count
- Contact information
- Company details
- Performance history

---

### 10. Contract Timeline Screen

**Purpose:** Visual timeline of contract progress

**UI Layout:**
```
┌─────────────────────────────────────┐
│  ← Back    Contract Timeline         │
│                                     │
│  Road Construction Project           │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Timeline View                │   │
│  │                             │   │
│  │ Jan 1  ── Contract Start    │   │
│  │   │                         │   │
│  │ Jan 5  ── First Report ✓    │   │
│  │   │                         │   │
│  │ Jan 10 ── Report Approved ✓  │   │
│  │   │                         │   │
│  │ Jan 15 ── Current Report    │   │
│  │   │      (Pending)          │   │
│  │   │                         │   │
│  │ Dec 31 ── Expected End      │   │
│  └─────────────────────────────┘   │
│                                     │
│  Daily Reports                      │
│  ┌─────────────────────────────┐   │
│  │ Jan 15 - Pending Validation │   │
│  │ Jan 14 - Approved ✓          │   │
│  │ Jan 13 - Approved ✓          │   │
│  │ [View All]                   │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- Visual timeline
- Milestone markers
- Progress indicators
- Daily report history
- Status indicators
- Date navigation

---

## Role-Based UI Differences

### Navigation Structure by Role

**Admin:**
- Home/Dashboard
- Contracts (Create, Manage)
- Projects (Internal)
- Directory (All)
- Reports (Full Access)
- Users (Management)
- Settings
- Profile

**Agent:**
- Home/Dashboard
- Contracts (Assigned)
- Validations (Pending)
- Field Verification
- Reports (Assigned Contracts)
- Profile

**Contractor:**
- Home/Dashboard
- Contracts (My Contracts)
- Daily Reports (Submit)
- Reports (My Reports)
- Profile

**Agency:**
- Home/Dashboard
- Contracts (Assigned)
- Quality Assurance
- Reports (Assigned)
- Profile

**Public:**
- Home/Dashboard
- Contracts (View Only)
- Map View
- Reports (Public)
- Profile

---

## Screen Flow Diagrams

### Contractor Flow

```
Dashboard
    │
    ▼
My Contracts
    │
    ▼
Contract Detail
    │
    ▼
Submit Daily Report
    │
    ├── Enter Progress
    ├── Upload Images/Videos
    ├── Add Comments
    └── Submit
    │
    ▼
Report Submitted
    │
    ▼
Wait for Validation
    │
    ▼
Report Approved/Rejected
```

### Agent Flow

```
Dashboard
    │
    ▼
Pending Validations
    │
    ▼
Report Detail
    │
    ├── Review Report
    ├── View Media
    ├── Field Verification (Optional)
    └── Validate
    │
    ▼
Approve/Reject
    │
    ▼
Validation Complete
```

### Admin Flow

```
Dashboard
    │
    ▼
Contracts List
    │
    ├── Create New Contract
    ├── View Contract Details
    ├── Assign Contractors/Agents
    └── Manage Contracts
    │
    ▼
Reports Dashboard
    │
    ├── View Analytics
    ├── Generate Reports
    └── Export Data
```

---

## Design Guidelines

### Typography
- **Headings:** Bold, 24-32px
- **Body Text:** Regular, 16-18px
- **Labels:** Regular, 14px
- **Small Text:** Regular, 12px

### Spacing
- **Screen Padding:** 16-20px
- **Element Spacing:** 12-16px
- **Card Padding:** 16px
- **Button Height:** 48-56px

### Icons
- **Size:** 24-32px for main actions
- **Style:** Outlined or filled
- **Color:** Match status/role colors

### Status Indicators
- **Draft:** Gray circle
- **Active:** Blue circle
- **Pending:** Yellow/orange circle
- **Approved:** Green checkmark
- **Rejected:** Red X
- **Completed:** Dark green checkmark

---

**Document Version:** 1.0  
**Last Updated:** [Current Date]  
**Status:** Part 1 of UI/UX Specification

---

*This is Part 1 of the UI/UX specification. Additional detailed screen specifications will follow in subsequent documents.*

