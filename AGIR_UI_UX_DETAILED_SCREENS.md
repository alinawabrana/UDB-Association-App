# Agir - Detailed Screen Specifications
## Part 2: Complete UI/UX Documentation

---

## Table of Contents

1. [Detailed Screen Specifications](#detailed-screen-specifications)
2. [User Interactions & Gestures](#user-interactions--gestures)
3. [Component Library](#component-library)
4. [State Management](#state-management)
5. [Accessibility Guidelines](#accessibility-guidelines)

---

## Detailed Screen Specifications

### Screen 1: Contracts List Screen (Detailed)

**Purpose:** Primary interface for viewing and managing contracts

**User Roles:** All (with role-based filtering)

**UI Components:**

#### Header Section
```
┌─────────────────────────────────────┐
│  ☰ Menu    Contracts    [Notifications]│
│                                     │
│  [Search Bar with Filter Icon]      │
│                                     │
│  Quick Filters:                     │
│  [All] [Active] [In Progress]       │
│  [Completed] [Pending]             │
│                                     │
│  [+ New Contract] (Admin only)     │
└─────────────────────────────────────┘
```

#### Contract Card Component
```
┌─────────────────────────────────────┐
│  Contract Card                      │
│  ┌─────────────────────────────┐   │
│  │ [Status Badge]              │   │
│  │ Road Construction Project   │   │
│  │                             │   │
│  │ Amount: $20,000,000,000     │   │
│  │ Progress: [████░░░░] 45%    │   │
│  │                             │   │
│  │ 📍 Libreville, Gabon        │   │
│  │ 👷 ABC Construction         │   │
│  │ 👤 Agent: John Doe          │   │
│  │                             │   │
│  │ Last Update: Today 2:30 PM  │   │
│  └─────────────────────────────┘   │
│                                     │
│  [View Details] [Quick Actions]     │
└─────────────────────────────────────┘
```

**Interactions:**
- Tap card → Navigate to Contract Detail
- Swipe left → Quick actions (role-based)
- Long press → Context menu
- Pull to refresh → Reload contracts

**Filtering Options:**
- By Status (All, Active, In Progress, Completed, Pending)
- By Contractor
- By Agent
- By Location/Region
- By Amount Range
- By Date Range

**Sorting Options:**
- Date (Newest/Oldest)
- Amount (High/Low)
- Progress (High/Low)
- Status

---

### Screen 2: Contract Detail Screen (Detailed)

**Purpose:** Comprehensive contract information and management

**User Roles:** All (with role-based actions)

**Tab Structure:**
```
┌─────────────────────────────────────┐
│  Contract: Road Construction       │
│                                     │
│  [Overview] [Reports] [Timeline]     │
│  [Documents] [Team]                 │
│                                     │
└─────────────────────────────────────┘
```

#### Tab 1: Overview
```
┌─────────────────────────────────────┐
│  Contract Information              │
│  ┌─────────────────────────────┐   │
│  │ ID: CNT-2025-001            │   │
│  │ Status: In Progress         │   │
│  │ Amount: $20,000,000,000     │   │
│  │ Progress: 45%               │   │
│  │ Start: Jan 1, 2025          │   │
│  │ End: Dec 31, 2025          │   │
│  └─────────────────────────────┘   │
│                                     │
│  Description                        │
│  [Contract description text...]     │
│                                     │
│  Location                           │
│  ┌─────────────────────────────┐   │
│  │ [Interactive Map]            │   │
│  │ 📍 Libreville, Gabon         │   │
│  │ [Get Directions]            │   │
│  └─────────────────────────────┘   │
│                                     │
│  Budget Breakdown                   │
│  ┌─────────────────────────────┐   │
│  │ Materials: $10B (50%)         │   │
│  │ Labor: $5B (25%)             │   │
│  │ Equipment: $3B (15%)         │   │
│  │ Other: $2B (10%)              │   │
│  │ [Progress Bars]              │   │
│  └─────────────────────────────┘   │
│                                     │
│  Milestones                         │
│  ┌─────────────────────────────┐   │
│  │ ✓ Foundation Complete        │   │
│  │ ⏳ Road Paving (50%)         │   │
│  │ ⏸️ Final Inspection          │   │
│  └─────────────────────────────┘   │
│                                     │
│  Quick Actions                      │
│  [Role-based action buttons]        │
└─────────────────────────────────────┘
```

#### Tab 2: Reports
```
┌─────────────────────────────────────┐
│  Daily Reports                       │
│                                     │
│  Filter: [All] [Pending] [Approved] │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Jan 15, 2025                │   │
│  │ Progress: 45%               │   │
│  │ Status: Pending Validation  │   │
│  │ Submitted by: ABC Const.    │   │
│  │ [View Report]               │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Jan 14, 2025                │   │
│  │ Progress: 44%               │   │
│  │ Status: ✓ Approved          │   │
│  │ Validated by: John Doe      │   │
│  │ [View Report]               │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Load More]                        │
└─────────────────────────────────────┘
```

#### Tab 3: Timeline
- Visual timeline view
- Milestone markers
- Daily report markers
- Progress indicators

#### Tab 4: Documents
- Contract documents
- Technical specifications
- Approved reports
- Media gallery

#### Tab 5: Team
- Assigned contractor
- Monitoring agents
- Agency (if assigned)
- Contact information

---

### Screen 3: Daily Report Detail Screen

**Purpose:** View complete daily report with media

**UI Layout:**
```
┌─────────────────────────────────────┐
│  ← Back    Daily Report              │
│                                     │
│  Contract: Road Construction        │
│  Date: January 15, 2025             │
│  Status: Pending Validation          │
│                                     │
│  Progress: 45%                      │
│  [Progress Bar]                      │
│                                     │
│  Work Completed                     │
│  ┌─────────────────────────────┐   │
│  │ [Contractor's description]   │   │
│  └─────────────────────────────┘   │
│                                     │
│  Images (6)                         │
│  ┌─────────────────────────────┐   │
│  │ [Gallery Grid]               │   │
│  │ [Img1] [Img2] [Img3]         │   │
│  │ [Img4] [Img5] [Img6]         │   │
│  │ [View All Images]            │   │
│  └─────────────────────────────┘   │
│                                     │
│  Videos (2)                          │
│  ┌─────────────────────────────┐   │
│  │ [Video Thumbnail 1]          │   │
│  │ [Video Thumbnail 2]          │   │
│  │ [Play Video]                 │   │
│  └─────────────────────────────┘   │
│                                     │
│  Contractor Comments                │
│  ┌─────────────────────────────┐   │
│  │ [Comments section]           │   │
│  └─────────────────────────────┘   │
│                                     │
│  Validation Section (Agent View)     │
│  ┌─────────────────────────────┐   │
│  │ Verification Comments        │   │
│  │ [Agent's comments]           │   │
│  │                             │   │
│  │ Verification Media           │   │
│  │ [Agent's photos]             │   │
│  │                             │   │
│  │ [Approve] [Reject]           │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- Full-screen image viewer
- Video player
- Comment thread
- Validation actions (for agents)
- Media download (if approved)

---

### Screen 4: Report Submission Form (Detailed)

**Purpose:** Contractor submits daily progress report

**Step-by-Step Form:**

#### Step 1: Basic Information
```
┌─────────────────────────────────────┐
│  Step 1 of 3                        │
│  ████░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│                                     │
│  Contract: Road Construction        │
│  Date: January 15, 2025             │
│                                     │
│  Overall Progress                   │
│  ┌─────────────────────────────┐   │
│  │ [Slider: 0-100%]            │   │
│  │ Current: 45%                │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Next]                             │
└─────────────────────────────────────┘
```

#### Step 2: Work Description & Media
```
┌─────────────────────────────────────┐
│  Step 2 of 3                        │
│  ████████░░░░░░░░░░░░░░░░░░░░░░░░  │
│                                     │
│  Work Completed Today *             │
│  ┌─────────────────────────────┐   │
│  │ [Rich Text Editor]           │   │
│  │ Describe work completed...   │   │
│  └─────────────────────────────┘   │
│                                     │
│  Images * (Minimum 3 required)       │
│  ┌─────────────────────────────┐   │
│  │ [Image Grid]                 │   │
│  │ [Img1] [Img2] [Img3] [Add]   │   │
│  └─────────────────────────────┘   │
│                                     │
│  Videos (Optional)                  │
│  ┌─────────────────────────────┐   │
│  │ [Video Thumbnails]           │   │
│  │ [Video1] [Video2] [+ Add]    │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Back] [Next]                      │
└─────────────────────────────────────┘
```

#### Step 3: Additional Information
```
┌─────────────────────────────────────┐
│  Step 3 of 3                        │
│  ████████████████████████████████  │
│                                     │
│  Comments/Notes                      │
│  ┌─────────────────────────────┐   │
│  │ [Text Area]                  │   │
│  │ Additional notes...          │   │
│  └─────────────────────────────┘   │
│                                     │
│  Issues/Challenges (Optional)       │
│  ┌─────────────────────────────┐   │
│  │ [Text Area]                  │   │
│  │ Report any issues...         │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Back] [Submit Report]             │
└─────────────────────────────────────┘
```

**Form Validation:**
- Progress percentage required
- Work description required (min 50 characters)
- Minimum 3 images required
- Date validation
- File size limits (images: 10MB, videos: 100MB)

---

### Screen 5: Validation Interface (Detailed)

**Purpose:** Agent validates contractor reports

**UI Layout:**
```
┌─────────────────────────────────────┐
│  ← Back    Validate Report           │
│                                     │
│  Contract: Road Construction        │
│  Report Date: Jan 15, 2025         │
│  Contractor: ABC Construction       │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Status: ⏳ Pending          │   │
│  └─────────────────────────────┘   │
│                                     │
│  Reported Progress: 45%             │
│  Previous Progress: 44%             │
│  Progress Change: +1%               │
│                                     │
│  Work Description                   │
│  ┌─────────────────────────────┐   │
│  │ [Expandable text]            │   │
│  │ "Completed road paving..."   │   │
│  │ [Read More]                  │   │
│  └─────────────────────────────┘   │
│                                     │
│  Submitted Media                    │
│  ┌─────────────────────────────┐   │
│  │ Images (6)                  │   │
│  │ [Thumbnail Grid]            │   │
│  │ [View All]                  │   │
│  │                             │   │
│  │ Videos (2)                   │   │
│  │ [Video Thumbnails]           │   │
│  │ [Play]                       │   │
│  └─────────────────────────────┘   │
│                                     │
│  Field Verification                 │
│  ┌─────────────────────────────┐   │
│  │ [ ] Site Visited             │   │
│  │ [ ] Work Verified            │   │
│  │ [ ] Progress Confirmed       │   │
│  │ [ ] Quality Standards Met    │   │
│  └─────────────────────────────┘   │
│                                     │
│  Verification Comments *            │
│  ┌─────────────────────────────┐   │
│  │ [Text Area]                  │   │
│  │ Add verification notes...    │   │
│  └─────────────────────────────┘   │
│                                     │
│  Verification Media                 │
│  ┌─────────────────────────────┐   │
│  │ [Camera] [Gallery]           │   │
│  │ Add verification photos      │   │
│  └─────────────────────────────┘   │
│                                     │
│  Validation Decision                │
│  ┌─────────────────────────────┐   │
│  │ [✓ Approve] [✗ Reject]      │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Rejection Flow:**
If agent selects "Reject":
```
┌─────────────────────────────────────┐
│  Rejection Reason *                 │
│  ┌─────────────────────────────┐   │
│  │ [ ] Progress mismatch        │   │
│  │ [ ] Work not verified        │   │
│  │ [ ] Quality issues           │   │
│  │ [ ] Missing information      │   │
│  │ [ ] Other                    │   │
│  └─────────────────────────────┘   │
│                                     │
│  Detailed Feedback *                 │
│  ┌─────────────────────────────┐   │
│  │ [Text Area]                  │   │
│  │ Explain rejection reason...  │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Cancel] [Confirm Rejection]        │
└─────────────────────────────────────┘
```

---

### Screen 6: Reporting Dashboard (Detailed)

**Purpose:** Comprehensive analytics and reporting

**Dashboard Sections:**

#### Section 1: Key Metrics Cards
```
┌─────────────────────────────────────┐
│  Executive Summary                  │
│                                     │
│  ┌──────┐ ┌──────┐ ┌──────┐       │
│  │Total │ │Active│ │Spent │       │
│  │Cont. │ │Sites │ │Amount│       │
│  │ 125  │ │  45  │ │$2.5B │       │
│  │      │ │      │ │      │       │
│  │ +5   │ │ +2   │ │+$200M│       │
│  │this  │ │this  │ │this  │       │
│  │month │ │week  │ │month │       │
│  └──────┘ └──────┘ └──────┘       │
│                                     │
│  ┌──────┐ ┌──────┐ ┌──────┐       │
│  │Comp. │ │Contr.│ │Avg.  │       │
│  │Cont. │ │Count │ │Dur.  │       │
│  │  80  │ │  32  │ │180d  │       │
│  └──────┘ └──────┘ └──────┘       │
└─────────────────────────────────────┘
```

#### Section 2: Contract Status Chart
```
┌─────────────────────────────────────┐
│  Contract Status Distribution        │
│  ┌─────────────────────────────┐   │
│  │ [Pie Chart]                 │   │
│  │                             │   │
│  │ Active: 40 (32%)            │   │
│  │ In Progress: 45 (36%)       │   │
│  │ Completed: 80 (64%)         │   │
│  │ Pending: 5 (4%)             │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

#### Section 3: Spending Over Time
```
┌─────────────────────────────────────┐
│  Spending Trend                      │
│  ┌─────────────────────────────┐   │
│  │ [Line Chart]                │   │
│  │ Monthly spending            │   │
│  │ Jan | Feb | Mar | Apr...    │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

#### Section 4: Progress by Contract
```
┌─────────────────────────────────────┐
│  Contract Progress                   │
│  ┌─────────────────────────────┐   │
│  │ [Horizontal Bar Chart]       │   │
│  │                             │   │
│  │ Road Project      [████░░] 45%│   │
│  │ Bridge Project    [███░░░] 30%│   │
│  │ School Project    [█████░] 50%│   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

#### Section 5: Geographic Distribution
```
┌─────────────────────────────────────┐
│  Contracts by Location               │
│  ┌─────────────────────────────┐   │
│  │ [Map View]                   │   │
│  │ With contract markers        │   │
│  │ [Toggle: Map | List]         │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

**Export Options:**
- Export as PDF
- Export as Excel
- Export as CSV
- Share report
- Schedule automated reports

---

### Screen 7: Map View Screen (Detailed)

**Purpose:** Geographic visualization of all contracts

**UI Components:**

#### Map Interface
```
┌─────────────────────────────────────┐
│  ☰ Menu    Contract Map             │
│                                     │
│  [Search] [Filter] [List View]      │
│                                     │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │   [Interactive Map]          │   │
│  │                             │   │
│  │   [Marker 1] [Marker 2]     │   │
│  │   [Cluster: 5 contracts]    │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  Legend                             │
│  • 🔵 Active (40)                  │
│  • 🟠 In Progress (45)             │
│  • 🟢 Completed (80)                │
│  • ⚪ Pending (5)                  │
│                                     │
│  Filter Panel                       │
│  ┌─────────────────────────────┐   │
│  │ Status: [All ▼]             │   │
│  │ Type: [All ▼]               │   │
│  │ Region: [All ▼]              │   │
│  │ Amount: [Range Slider]       │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Reset Filters]                    │
└─────────────────────────────────────┘
```

**Map Features:**
- Zoom controls
- My location button
- Cluster markers for multiple contracts
- Info window on marker tap
- Route planning
- Satellite/Map view toggle
- Full-screen mode

**Marker Info Window:**
```
┌─────────────────────────────────────┐
│  Road Construction Project          │
│  Amount: $20B                       │
│  Progress: 45%                      │
│  Status: In Progress                │
│                                     │
│  [View Details] [Get Directions]    │
└─────────────────────────────────────┘
```

---

### Screen 8: Supplier Detail Screen

**Purpose:** Detailed supplier/contractor/agency information

**UI Layout:**
```
┌─────────────────────────────────────┐
│  ← Back    Supplier Details         │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [Company Logo]               │   │
│  │ ABC Construction             │   │
│  │ Type: Contractor             │   │
│  │ Rating: ⭐⭐⭐⭐ (4.5)        │   │
│  └─────────────────────────────┘   │
│                                     │
│  Contact Information                │
│  ┌─────────────────────────────┐   │
│  │ 📧 contact@abc.com          │   │
│  │ 📞 +241 123 456 789          │   │
│  │ 📍 Address, Libreville       │   │
│  └─────────────────────────────┘   │
│                                     │
│  Performance Metrics                │
│  ┌─────────────────────────────┐   │
│  │ Active Contracts: 5          │   │
│  │ Completed: 12                 │   │
│  │ On-Time Delivery: 95%        │   │
│  │ Quality Rating: 4.5/5        │   │
│  └─────────────────────────────┘   │
│                                     │
│  Active Contracts                   │
│  ┌─────────────────────────────┐   │
│  │ Road Project - $20B          │   │
│  │ Bridge Project - $5B         │   │
│  │ [View All]                   │   │
│  └─────────────────────────────┘   │
│                                     │
│  Documents                          │
│  ┌─────────────────────────────┐   │
│  │ Registration Certificate     │   │
│  │ License Document            │   │
│  │ [View All]                  │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Contact] [Assign to Contract]     │
│                                     │
└─────────────────────────────────────┘
```

---

## User Interactions & Gestures

### Common Gestures

**Tap:**
- Select item
- Navigate to detail
- Trigger action

**Long Press:**
- Context menu
- Quick actions
- Item selection

**Swipe:**
- Left: Quick actions (role-based)
- Right: Navigate back
- Down: Refresh list
- Up: Scroll

**Pull to Refresh:**
- Contract list
- Report list
- Dashboard metrics

**Pinch to Zoom:**
- Map view
- Image viewer
- Charts

---

## Component Library

### Status Badges

**Contract Status:**
- Draft: Gray badge
- Active: Blue badge
- In Progress: Orange badge
- Pending Validation: Yellow badge
- Approved: Green badge
- Rejected: Red badge
- Completed: Dark green badge

### Progress Indicators

**Progress Bar:**
```
[████████░░░░░░░░░░] 45%
```

**Circular Progress:**
```
    ┌───┐
    │45%│
    └───┘
```

### Media Components

**Image Gallery:**
- Grid view
- Full-screen viewer
- Swipe navigation
- Zoom capability

**Video Player:**
- Thumbnail preview
- Full-screen playback
- Playback controls
- Download option (if approved)

### Form Components

**Input Fields:**
- Text input
- Number input
- Date picker
- Dropdown/Select
- Multi-select
- File upload
- Map picker

**Validation:**
- Real-time validation
- Error messages
- Success indicators
- Required field markers

---

## State Management

### Screen States

**Loading State:**
- Skeleton screens
- Loading spinners
- Progress indicators

**Empty State:**
- Empty list messages
- Action prompts
- Illustration placeholders

**Error State:**
- Error messages
- Retry buttons
- Error illustrations

**Success State:**
- Success messages
- Confirmation animations
- Next action prompts

---

## Accessibility Guidelines

### Text Accessibility
- Minimum font size: 14px
- High contrast ratios
- Readable fonts
- Scalable text

### Touch Targets
- Minimum size: 44x44 pixels
- Adequate spacing between targets
- Clear tap areas

### Color Accessibility
- Don't rely solely on color
- Use icons and text labels
- Support color blindness
- High contrast mode

### Screen Reader Support
- Semantic HTML/Widgets
- Alt text for images
- ARIA labels
- Descriptive button labels

---

**Document Version:** 1.0  
**Last Updated:** [Current Date]  
**Status:** Part 2 of UI/UX Specification

---

*This document provides detailed screen specifications for the Agir application. Refer to Part 1 for screen classification and overview.*


