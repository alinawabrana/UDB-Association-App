# Agir - Screen Comparison & Implementation Guide
## UDB Association vs Agir Application

---

## Quick Reference Table

| Screen Name | UDB Association | Agir Status | Changes Required |
|------------|-----------------|-------------|------------------|
| Welcome Screen | ✅ Exists | ✅ Keep | Minor (Branding) |
| Sign In Screen | ✅ Exists | ✅ Keep | Minimal |
| Sign Up Screen | ✅ Exists | ✅ Modify | Moderate (Remove "Member", Add "Civil Servant") |
| Home Screen | ✅ Exists | ✅ Modify | Major (Role-based Dashboard) |
| News Screen | ✅ Exists | ⚠️ Optional | Decision Required |
| Event Screen | ✅ Exists | ❌ Remove | Not needed for government |
| Organes Screen | ✅ Exists | ✅ Modify | Major (Adapt for Government Structure) |
| Directory Screen | ✅ Exists | ✅ Modify | Major (Add Suppliers) |
| Project Screen | ✅ Exists | ✅ Modify | Moderate (Internal Projects Only) |
| Shop Screen | ✅ Exists | ❌ Remove | Not needed for government |
| Profile Screen | ✅ Exists | ✅ Modify | Moderate (Remove "Member ID") |
| Contracts List | ❌ New | ✅ New | **NEW SCREEN** |
| Contract Detail | ❌ New | ✅ New | **NEW SCREEN** |
| Contract Creation | ❌ New | ✅ New | **NEW SCREEN** |
| Daily Report Submission | ❌ New | ✅ New | **NEW SCREEN** |
| Daily Report Validation | ❌ New | ✅ New | **NEW SCREEN** |
| Field Verification | ❌ New | ✅ New | **NEW SCREEN** |
| Reporting Dashboard | ❌ New | ✅ New | **NEW SCREEN** |
| Map View | ❌ New | ✅ New | **NEW SCREEN** |
| Supplier Directory | ❌ New | ✅ New | **NEW SCREEN** |
| Contract Timeline | ❌ New | ✅ New | **NEW SCREEN** |

---

## Detailed Screen Analysis

### ✅ Screens That Remain (Minimal Changes)

#### 1. Welcome Screen
**Status:** Keep with minor changes

**Changes:**
- Update app name: "UDB Association" → "Agir"
- Update tagline: "Association Platform" → "Intelligent Resource Management"
- Update description text
- Keep same layout and structure

**Effort:** Low

---

#### 2. Sign In Screen
**Status:** Keep with minimal changes

**Changes:**
- Update app branding
- Keep same form structure
- Optional: Add role selector (if user has multiple roles)

**Effort:** Very Low

---

### ✅ Screens Requiring Modification

#### 1. Sign Up Screen
**Status:** Moderate modification

**Remove:**
- "Member" terminology
- Association-specific fields
- Member-related options

**Add:**
- Organization/Department field
- Employee ID field
- Position/Title field
- Role selection (Agent/Admin/Public)
- Government employee verification

**Modify:**
- Form labels and placeholders
- Validation rules
- Success messages

**Effort:** Medium

---

#### 2. Home Screen → Dashboard
**Status:** Major modification

**Original Functionality:**
- Association news and updates
- Member information
- Association-specific content

**New Functionality:**
- Role-based dashboard
- Contract overview (for relevant roles)
- Pending validations (for agents)
- Daily reports (for contractors)
- Key metrics (for admins)
- Public transparency view (for public users)

**Changes:**
- Complete redesign of content area
- Role-based widget system
- Metrics cards
- Quick action buttons
- Recent activity feed

**Effort:** High

---

#### 3. Projects Screen → Internal Projects
**Status:** Moderate modification

**Keep:**
- Project list view
- Project status cards
- Progress tracking
- Task management

**Remove:**
- Association-specific features
- Member collaboration
- Public project visibility

**Add:**
- Internal team assignment
- Government department filtering
- Internal document sharing
- Administration-specific workflows

**Modify:**
- Terminology (remove "member")
- Access controls (internal only)
- Project types (internal works)

**Effort:** Medium

---

#### 4. Directory Screen → Enhanced Directory
**Status:** Major modification

**Keep:**
- Directory list view
- Search functionality
- Contact information

**Add:**
- **Suppliers Section:**
  - Contractors list
  - Agencies list
  - Performance ratings
  - Active contracts count
  - Company details

- **Enhanced Filtering:**
  - Filter by type (Contractor/Agency/Agent)
  - Filter by performance rating
  - Filter by active contracts

- **New Information:**
  - Supplier registration details
  - Certifications
  - Contract history
  - Performance metrics

**Modify:**
- Add "Suppliers" tab/section
- Enhance agent information
- Add organization/department info

**Effort:** High

---

#### 5. Organes Screen
**Status:** Major modification

**Original:**
- UDB Association divisions
- UDB branches
- Association members

**New:**
- Government administration structure
- Departments
- Agencies
- Civil servants (instead of members)

**Changes:**
- Replace association structure with government structure
- Update terminology
- Adapt for government hierarchy
- Remove association-specific features

**Effort:** High

---

#### 6. Profile Screen
**Status:** Moderate modification

**Remove:**
- "Member ID" → Replace with "Employee ID" or "User ID"
- Association-specific information
- Member-related features

**Add:**
- Organization/Department display
- Role badge
- Government employee information
- Role-specific settings

**Modify:**
- Terminology throughout
- Profile information fields
- Settings options

**Effort:** Medium

---

#### 7. News Screen
**Status:** Optional - Decision Required

**Options:**
1. **Remove entirely** - Not needed for government app
2. **Keep and adapt** - For government announcements
3. **Replace** - With contract announcements/notices

**If Kept:**
- Government announcements
- Contract awards
- Public notices
- System updates

**Effort:** Low (if removed) or Medium (if adapted)

---

### ❌ Screens to Remove

#### 1. Event Screen (Calendar)
**Reason:** Not needed for government procurement management

**Action:** Remove entirely

---

#### 2. Shop Screen
**Reason:** E-commerce not part of government app

**Action:** Remove entirely

---

### ✅ New Screens to Implement

#### 1. Contracts List Screen
**Priority:** High  
**Complexity:** Medium

**Features:**
- Contract listing with cards
- Search and filter
- Status indicators
- Progress bars
- Map view toggle
- Sort options

**Dependencies:** Contract management backend

---

#### 2. Contract Detail Screen
**Priority:** High  
**Complexity:** High

**Features:**
- Tab-based interface
- Overview, Reports, Timeline, Documents, Team
- Map integration
- Budget breakdown
- Milestone tracking
- Role-based actions

**Dependencies:** Contract data, Map service, Document storage

---

#### 3. Contract Creation Screen
**Priority:** High  
**Complexity:** High

**Features:**
- Multi-step form
- Contract information
- Financial details
- Location picker (map)
- Assignment (contractor, agents, agency)
- Budget breakdown
- Document upload

**Dependencies:** Supplier database, Map service, File storage

**Access:** Admin only

---

#### 4. Daily Report Submission Screen
**Priority:** High  
**Complexity:** Medium

**Features:**
- Multi-step form
- Progress input
- Work description
- Image upload (multiple, required)
- Video upload (optional)
- Comments section
- Draft save

**Dependencies:** Media storage, File upload service

**Access:** Contractors only

---

#### 5. Daily Report Validation Screen
**Priority:** High  
**Complexity:** High

**Features:**
- Report review interface
- Media gallery viewer
- Video player
- Field verification checklist
- Verification comments
- Verification media upload
- Approve/Reject actions

**Dependencies:** Report data, Media viewer, Validation workflow

**Access:** Agents and Agencies

---

#### 6. Field Verification Screen
**Priority:** Medium  
**Complexity:** Medium

**Features:**
- GPS location capture
- Map with directions
- Camera integration
- Video recording
- Verification checklist
- Notes and documentation
- Offline capability

**Dependencies:** GPS, Camera, Map service, Offline storage

**Access:** Agents and Agencies

---

#### 7. Reporting Dashboard Screen
**Priority:** High  
**Complexity:** High

**Features:**
- Key metrics cards
- Interactive charts
- Contract status visualization
- Spending trends
- Progress analytics
- Geographic distribution
- Export functionality

**Dependencies:** Analytics engine, Chart library, Export service

**Access:** All roles (with role-based data)

---

#### 8. Map View Screen
**Priority:** High  
**Complexity:** Medium

**Features:**
- Interactive map
- Contract markers
- Cluster view
- Filter by status/type/region
- Info windows
- Route planning
- List view toggle

**Dependencies:** Map service API, Contract location data

**Access:** All roles

---

#### 9. Supplier Directory Screen
**Priority:** Medium  
**Complexity:** Low

**Features:**
- Supplier listing
- Search and filter
- Performance ratings
- Active contract count
- Contact information
- Company details

**Dependencies:** Supplier database

**Access:** All roles (with role-based visibility)

---

#### 10. Contract Timeline Screen
**Priority:** Medium  
**Complexity:** Low

**Features:**
- Visual timeline
- Milestone markers
- Daily report markers
- Progress indicators
- Date navigation

**Dependencies:** Contract data, Report history

**Access:** All roles

---

## Implementation Priority

### Phase 1: Core Screens (Must Have)
1. ✅ Modified Home/Dashboard
2. ✅ Contracts List Screen
3. ✅ Contract Detail Screen
4. ✅ Contract Creation Screen
5. ✅ Daily Report Submission Screen
6. ✅ Daily Report Validation Screen

### Phase 2: Essential Features
7. ✅ Reporting Dashboard Screen
8. ✅ Map View Screen
9. ✅ Modified Directory Screen
10. ✅ Modified Profile Screen

### Phase 3: Enhanced Features
11. ✅ Field Verification Screen
12. ✅ Supplier Directory Screen
13. ✅ Contract Timeline Screen
14. ✅ Modified Internal Projects Screen

### Phase 4: Optional/Polish
15. ⚠️ News Screen (if kept)
16. ✅ Welcome/Sign In/Sign Up (updates)

---

## Screen Count Summary

**Total Screens in Agir:** ~20-22 screens

**Breakdown:**
- **Remaining (Modified):** 6-7 screens
- **New Screens:** 10 screens
- **Removed:** 2 screens (Event, Shop)
- **Optional:** 1 screen (News)

---

## Navigation Structure Comparison

### UDB Association Navigation:
```
Bottom Navigation:
- Home
- News
- Events
- ORGANES
- Directory/Projects/Shop/Profile
```

### Agir Navigation (Role-Based):

**Admin:**
```
Bottom Navigation:
- Dashboard
- Contracts
- Projects (Internal)
- Directory
- Reports
- Profile
```

**Agent:**
```
Bottom Navigation:
- Dashboard
- Contracts (Assigned)
- Validations
- Reports
- Profile
```

**Contractor:**
```
Bottom Navigation:
- Dashboard
- Contracts (My Contracts)
- Daily Reports
- Reports
- Profile
```

**Public:**
```
Bottom Navigation:
- Dashboard
- Contracts (View)
- Map
- Reports (Public)
- Profile
```

---

## Key Design Differences

### Terminology Changes:
- "Member" → "User" or "Civil Servant"
- "Member ID" → "Employee ID" or "User ID"
- "Association" → "Government" or "Administration"
- "Shop" → Removed
- "Events" → Removed

### New Terminology:
- "Contract"
- "Daily Report"
- "Validation"
- "Field Verification"
- "Supplier" (Contractor/Agency)
- "Agent" (Monitoring Agent)
- "Public" (Public User)

### Color Scheme Adaptations:
- Keep primary green (government trust)
- Add status colors (Pending, Approved, Rejected)
- Emphasize transparency colors
- Professional government aesthetic

---

## Development Checklist

### Screens to Modify:
- [ ] Welcome Screen (Branding)
- [ ] Sign In Screen (Minimal)
- [ ] Sign Up Screen (Moderate)
- [ ] Home/Dashboard (Major)
- [ ] Projects Screen (Moderate)
- [ ] Directory Screen (Major)
- [ ] Organes Screen (Major)
- [ ] Profile Screen (Moderate)

### New Screens to Build:
- [ ] Contracts List Screen
- [ ] Contract Detail Screen
- [ ] Contract Creation Screen
- [ ] Daily Report Submission Screen
- [ ] Daily Report Validation Screen
- [ ] Field Verification Screen
- [ ] Reporting Dashboard Screen
- [ ] Map View Screen
- [ ] Supplier Directory Screen
- [ ] Contract Timeline Screen

### Screens to Remove:
- [ ] Event Screen
- [ ] Shop Screen

### Optional:
- [ ] News Screen (Decision required)

---

**Document Version:** 1.0  
**Last Updated:** [Current Date]  
**Status:** Implementation Guide

---

*This document provides a comprehensive comparison between UDB Association and Agir screens, helping developers understand what needs to be modified, created, or removed.*


