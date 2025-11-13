# 🎨 PANDUAN UX & IMPLEMENTASI - SPK Validasi Drone

**Target:** Frontend Developer (Flutter/React/Vue)  
**Tujuan:** Implementasi fitur Create SPK Validasi Drone dengan UX yang intuitif  
**Date:** 13 November 2025

---

## 🎯 **1. KONTEKS BISNIS**

### **Workflow Asisten Manager:**
```
1. Lihat data drone NDRE (pohon stress)
2. Analisis confusion matrix (akurasi prediksi)
3. **CREATE SPK** untuk validasi lapangan ⭐
4. Assign ke Mandor
5. Track progress SPK
```

**Problem:** Asisten Manager butuh **quick action** untuk create SPK dari berbagai konteks, tidak hanya dari menu navigasi.

---

## 📍 **2. PLACEMENT - Di Mana Tombol "Create SPK" Berada?**

### **A. Menu Navigasi Utama** (Sudah Pasti Ada)
```
Dashboard Asisten
├── 📊 Overview
├── 🚁 Drone NDRE Analysis
├── 📋 SPK Management
│   ├── 📝 Create SPK ← Menu entry point
│   ├── 📊 SPK List
│   └── 📈 SPK Statistics
└── 👥 Team Management
```

**Aksi:** Klik menu → Redirect ke halaman form Create SPK

---

### **B. Drone NDRE Analysis Page** ⭐ **PRIORITY 1**

**Konteks:** User sedang melihat list pohon stress dari hasil drone scan.

**Placement:**
```
┌─────────────────────────────────────────────────────────────┐
│ 🚁 Drone NDRE Analysis                        [🔄 Refresh] │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ 📊 Statistics Summary                                        │
│ ┌──────────────┬──────────────┬──────────────┐             │
│ │ Stres Berat  │ Stres Sedang │ Sehat        │             │
│ │   141 🔴     │   763 🟡     │   6 🟢       │             │
│ └──────────────┴──────────────┴──────────────┘             │
│                                                               │
│ 🎯 Quick Actions:                                            │
│ ┌────────────────────────────────────────────────────┐      │
│ │ ✅ 12 pohon selected                               │      │
│ │ [➕ Create SPK dari Selection] [🗑️ Clear]        │      │
│ └────────────────────────────────────────────────────┘      │
│                                                               │
│ 🌳 Tree List (Filterable)                                    │
│ ┌──────────────────────────────────────────────────────┐    │
│ │ [Filter: Stres Berat ▼] [Divisi: AME II ▼]         │    │
│ │ [☐ Select All] [Create SPK from Filter] ←BUTTON 2   │    │
│ └──────────────────────────────────────────────────────┘    │
│                                                               │
│ ┌───┬───────┬────────┬──────┬────────┬─────────────┐       │
│ │☑️ │Tree ID│ NDRE   │Class │ Blok   │ Action      │       │
│ ├───┼───────┼────────┼──────┼────────┼─────────────┤       │
│ │☑️ │T-001  │ 0.25   │🔴 SB │ D001A  │[📋 Detail] │       │
│ │☑️ │T-002  │ 0.32   │🔴 SB │ D001B  │[📋 Detail] │       │
│ │☐  │T-003  │ 0.48   │🟡 SS │ D002A  │[📋 Detail] │       │
│ └───┴───────┴────────┴──────┴────────┴─────────────┘       │
│                                                               │
│ [1] [2] [3] ... [15] Pages                                   │
└─────────────────────────────────────────────────────────────┘
```

**3 Cara Create SPK di Page Ini:**

1. **Selection-based (Recommended):**
   - User select checkbox pohon-pohon yang mau di-validasi
   - Tombol "Create SPK dari Selection" muncul (floating action button)
   - Quick, intuitive, user control penuh

2. **Filter-based:**
   - User apply filter (misal: Stres Berat + Divisi AME II)
   - Klik "Create SPK from Filter"
   - Otomatis create SPK untuk semua pohon yang match filter

3. **Bulk Action:**
   - Select All (semua pohon di page current)
   - Create SPK untuk batch besar

---

### **C. Confusion Matrix Page** ⭐ **PRIORITY 2**

**Konteks:** User lihat False Positive/False Negative tinggi → Butuh validasi ulang.

**Placement:**
```
┌─────────────────────────────────────────────────────────────┐
│ 📊 Confusion Matrix - Akurasi Prediksi Drone                │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ Metrics:                                                      │
│ • Accuracy: 94.8%   • Precision: 83.7%                       │
│ • Recall: 83.1%     • F1-Score: 83.4%                        │
│                                                               │
│        Aktual (Field Validation)                             │
│         Stress    │    Healthy                               │
│    ┌──────────────┼───────────────┐                          │
│ S  │ TP: 118 🟢  │ FP: 23 ⚠️     │                          │
│ t  ├──────────────┼───────────────┤                          │
│ r  │ FN: 24 ⚠️   │ TN: 745 🟢    │                          │
│ e  └──────────────┴───────────────┘                          │
│ s                                                             │
│ s                                                             │
│                                                               │
│ ⚠️ Recommendations:                                          │
│ ┌──────────────────────────────────────────────────────┐    │
│ │ FALSE POSITIVE (23 pohon):                           │    │
│ │ Prediksi stress tapi sehat. Penyebab: bayangan,     │    │
│ │ embun pagi, camera angle.                            │    │
│ │                                                       │    │
│ │ 🎯 Action: Naikkan NDRE threshold dari 0.45 ke 0.50  │    │
│ │ atau reschedule scan (hindari jam 06:00-08:00)      │    │
│ │                                                       │    │
│ │ [➕ Create SPK Validasi Ulang] ← BUTTON              │    │
│ └──────────────────────────────────────────────────────┘    │
│                                                               │
│ ┌──────────────────────────────────────────────────────┐    │
│ │ FALSE NEGATIVE (24 pohon):                           │    │
│ │ Prediksi sehat tapi stress. Missed detection drone. │    │
│ │                                                       │    │
│ │ 🎯 Action: Turunkan NDRE threshold dari 0.45 ke 0.40 │    │
│ │ atau tambahkan ground validation untuk borderline.  │    │
│ │                                                       │    │
│ │ [➕ Create SPK Validasi Ulang] ← BUTTON              │    │
│ └──────────────────────────────────────────────────────┘    │
│                                                               │
│ 💡 Quick Action:                                             │
│ [🔧 Adjust NDRE Threshold] [📋 View All Misclassified]      │
└─────────────────────────────────────────────────────────────┘
```

**Use Case:**
- User klik "Create SPK Validasi Ulang" pada FALSE POSITIVE/FALSE NEGATIVE
- Auto-populate SPK form dengan pohon-pohon yang salah prediksi
- Priority auto-set ke HIGH/URGENT

---

### **D. Tree Detail Modal/Page** (Optional - Nice to Have)

**Konteks:** User drill down ke detail 1 pohon.

**Placement:**
```
┌─────────────────────────────────────────────────────────────┐
│ 🌳 Tree Detail - T-001                          [✖️ Close] │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ Basic Info:                                                   │
│ • ID: T-001                    • Blok: D001A                 │
│ • Divisi: AME II               • Status: Active              │
│                                                               │
│ Latest Drone Scan (NDRE):                                    │
│ • NDRE Value: 0.25            • Classification: Stres Berat │
│ • Tanggal: 2025-11-10         • Confidence: 92%             │
│                                                               │
│ History:                                                      │
│ [Chart showing NDRE trend over time]                         │
│                                                               │
│ ⚠️ Urgent Action Required                                    │
│ [➕ Create SPK Validasi] [📍 View on Map] ← BUTTON          │
└─────────────────────────────────────────────────────────────┘
```

---

### **E. Dashboard Overview (Context-Aware Widget)** ⭐ **PRIORITY 3**

**Konteks:** User melihat overview metrics di dashboard utama.

**Placement:**
```
┌─────────────────────────────────────────────────────────────┐
│ 📊 Dashboard Asisten Manager                                 │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ ⚠️ Alerts & Quick Actions                                    │
│ ┌──────────────────────────────────────────────────────┐    │
│ │ 🚨 141 pohon dengan Stres Berat terdeteksi          │    │
│ │    (Butuh validasi lapangan segera!)                │    │
│ │    [➕ Create SPK Sekarang] ← FLOATING BUTTON        │    │
│ └──────────────────────────────────────────────────────┘    │
│                                                               │
│ ┌──────────────────────────────────────────────────────┐    │
│ │ ⚠️ False Negative Rate: 16.9% (High!)               │    │
│ │    24 pohon stress tidak terdeteksi drone            │    │
│ │    [📋 Review & Create SPK] ← ACTION BUTTON          │    │
│ └──────────────────────────────────────────────────────┘    │
│                                                               │
│ KPI Cards:                                                    │
│ [SPK Active: 7] [Completion: 42%] [Trees Validated: 234]    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎨 **3. UI/UX BEST PRACTICES**

### **Button Design:**

```css
/* Primary Action - Prominent */
.btn-create-spk-primary {
  background: #16a34a; /* Green */
  color: white;
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 600;
  box-shadow: 0 4px 12px rgba(22, 163, 74, 0.3);
  cursor: pointer;
}

/* Floating Action Button (FAB) - For Selection */
.btn-create-spk-fab {
  position: fixed;
  bottom: 24px;
  right: 24px;
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: #16a34a;
  color: white;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Secondary Action - Less Prominent */
.btn-create-spk-secondary {
  background: transparent;
  border: 2px solid #16a34a;
  color: #16a34a;
  padding: 10px 20px;
  border-radius: 6px;
}
```

### **Icon Choices:**
- ➕ `plus` icon untuk "Create New"
- 📋 `clipboard-list` untuk "SPK"
- 🚁 `drone` atau `plane` untuk drone context
- ✅ `check-circle` untuk validation

### **Button States:**

```javascript
// Disabled state (no selection)
if (selectedTrees.length === 0) {
  buttonText = "Select trees to create SPK";
  buttonDisabled = true;
  buttonStyle = "gray, cursor-not-allowed";
}

// Enabled state
if (selectedTrees.length > 0) {
  buttonText = `Create SPK (${selectedTrees.length} trees)`;
  buttonDisabled = false;
  buttonStyle = "green, cursor-pointer";
}

// Loading state
if (isCreating) {
  buttonText = "Creating SPK...";
  buttonDisabled = true;
  showSpinner = true;
}
```

---

## 🔧 **4. TECHNICAL IMPLEMENTATION**

### **A. Data Flow:**

```
[UI Selection/Filter]
     ↓
[Local State: selectedTreeIds[]]
     ↓
[Validation: Min 1 tree, Max 100 trees]
     ↓
[API Call: POST /api/v1/spk/validasi-drone]
     ↓
[Success: Show toast + Redirect to SPK detail]
     ↓
[Error: Show error message + Retry option]
```

### **B. API Integration:**

**Endpoint:** `POST /api/v1/spk/validasi-drone`

**Request Payload:**
```javascript
const payload = {
  created_by: currentUser.id, // From auth context
  assigned_to: selectedMandor.id, // From modal selection
  trees: selectedTreeIds, // Array of UUIDs
  priority: calculatePriority(selectedTrees), // AUTO or MANUAL
  notes: userNotes || `Validasi ${selectedTrees.length} pohon dari analisis drone NDRE`,
  deadline: calculateDeadline(priority) // Optional, backend auto-calc
};

// POST request
const response = await fetch('http://localhost:3000/api/v1/spk/validasi-drone', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${authToken}` // If RBAC enabled
  },
  body: JSON.stringify(payload)
});
```

**Response Handling:**
```javascript
if (response.ok) {
  const data = await response.json();
  
  // Show success toast
  showToast({
    type: 'success',
    title: 'SPK Created Successfully!',
    message: `SPK ${data.data.spk.no_spk} created with ${data.data.summary.total_trees} tasks`,
    duration: 5000
  });
  
  // Redirect to SPK detail
  router.push(`/spk/${data.data.spk.id_spk}`);
  
  // Or stay on page and refresh list
  refreshSPKList();
  
} else {
  const error = await response.json();
  
  // Show error toast
  showToast({
    type: 'error',
    title: 'Failed to Create SPK',
    message: error.message || 'An error occurred',
    action: {
      label: 'Retry',
      onClick: () => retryCreateSPK(payload)
    }
  });
}
```

---

### **C. Pre-Flight Checks:**

**Sebelum create SPK, validasi:**

```javascript
async function validateBeforeCreateSPK(selectedTreeIds) {
  const errors = [];
  
  // 1. Check tree count
  if (selectedTreeIds.length === 0) {
    errors.push('Please select at least 1 tree');
  }
  
  if (selectedTreeIds.length > 100) {
    errors.push('Maximum 100 trees per SPK');
  }
  
  // 2. Verify trees have NDRE data
  const treesWithoutNDRE = await checkTreesHaveNDRE(selectedTreeIds);
  if (treesWithoutNDRE.length > 0) {
    errors.push(`${treesWithoutNDRE.length} trees don't have NDRE data`);
  }
  
  // 3. Check user permissions
  if (!currentUser.roles.includes('ASISTEN') && !currentUser.roles.includes('ADMIN')) {
    errors.push('You don\'t have permission to create SPK');
  }
  
  // 4. Verify mandor availability
  const mandorList = await getMandorList();
  if (mandorList.length === 0) {
    errors.push('No mandor available for assignment');
  }
  
  return errors;
}
```

---

### **D. Modal/Dialog for Create SPK:**

**Recommended: Use Modal for Additional Inputs**

```javascript
// When user clicks "Create SPK" button
function handleCreateSPKClick() {
  // Validate selection
  const errors = validateBeforeCreateSPK(selectedTreeIds);
  if (errors.length > 0) {
    showErrorDialog(errors);
    return;
  }
  
  // Open modal for additional inputs
  openModal({
    title: 'Create SPK Validasi Drone',
    component: CreateSPKModal,
    props: {
      selectedTrees: selectedTrees, // Full tree objects
      defaultPriority: calculatePriority(selectedTrees),
      onSubmit: handleSPKSubmit,
      onCancel: closeModal
    }
  });
}
```

**Modal Content:**
```
┌─────────────────────────────────────────────────────────────┐
│ Create SPK Validasi Drone                        [✖️ Close] │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ 🌳 Selected Trees: 12                                        │
│ ┌──────────────────────────────────────────────────────┐    │
│ │ • Stres Berat: 8 trees                               │    │
│ │ • Stres Sedang: 4 trees                              │    │
│ │ • Blok: D001A (5), D001B (4), D002A (3)              │    │
│ └──────────────────────────────────────────────────────┘    │
│                                                               │
│ 👤 Assign to Mandor: *                                       │
│ [Select Mandor ▼]                                            │
│                                                               │
│ ⚡ Priority: (Auto-calculated)                               │
│ [🔴 URGENT] [🟡 HIGH] [🟢 NORMAL]                            │
│                                                               │
│ 📅 Target Completion:                                        │
│ [2025-11-20] (7 days from now)                               │
│                                                               │
│ 📝 Notes: (Optional)                                         │
│ [Textarea: Validasi urgent untuk...]                        │
│                                                               │
│ ────────────────────────────────────────────────────────     │
│                                                               │
│ [Cancel]                         [Create SPK →] ← PRIMARY   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧪 **5. USER FLOW EXAMPLES**

### **Flow 1: Create SPK dari Drone NDRE List**

```
Step 1: User masuk ke "Drone NDRE Analysis"
        ↓
Step 2: Filter pohon "Stres Berat"
        → Shows: 141 trees
        ↓
Step 3: Select 15 trees (checkbox)
        → Button muncul: "Create SPK (15 trees)"
        ↓
Step 4: Click "Create SPK"
        → Modal popup dengan pre-filled data
        ↓
Step 5: User pilih Mandor dari dropdown
        ↓
Step 6: Review priority (auto: URGENT)
        ↓
Step 7: Add notes (optional)
        ↓
Step 8: Click "Create SPK"
        → API call → Success
        ↓
Step 9: Toast notification: "SPK-DRONE-123 created!"
        ↓
Step 10: Redirect ke SPK detail page
         → User sees SPK with 15 tasks
```

### **Flow 2: Create SPK dari Confusion Matrix (False Negative)**

```
Step 1: User masuk ke "Confusion Matrix"
        → Sees: FN = 24 trees (16.9%)
        ↓
Step 2: Click "Create SPK Validasi Ulang" di card False Negative
        → Modal popup
        → Auto-populated dengan 24 trees yang FN
        → Priority auto: HIGH
        ↓
Step 3: User pilih Mandor
        ↓
Step 4: Add notes: "Re-validasi untuk false negative cases"
        ↓
Step 5: Click "Create SPK"
        → API call → Success
        ↓
Step 6: Redirect ke SPK detail
         → Mandor dapat notifikasi assignment
```

---

## 📱 **6. RESPONSIVE DESIGN**

### **Desktop (> 1024px):**
- Full table dengan checkboxes
- FAB bottom-right corner
- Modal center screen (max-width: 600px)

### **Tablet (768px - 1024px):**
- Compact table (hide non-essential columns)
- FAB bottom-right
- Modal full-width dengan padding

### **Mobile (< 768px):**
- Card-based list (no table)
- FAB bottom-center
- Modal full-screen (drawer style)
- Swipe actions untuk select/deselect

---

## 🎯 **7. KEY RECOMMENDATIONS**

### **Priority Implementation Order:**

1. ⭐ **Drone NDRE Analysis Page** (Most Common Use Case)
   - Selection-based create SPK
   - Filter-based create SPK
   - Implementation time: ~2-3 days

2. ⭐ **Confusion Matrix Page** (High Value, Actionable)
   - Quick action buttons untuk FP/FN
   - Auto-populate problem trees
   - Implementation time: ~1 day

3. ⭐ **Dashboard Overview Widget** (Visibility)
   - Alert cards dengan quick action
   - Implementation time: ~1 day

4. 🌟 **Menu Navigation** (Always Available)
   - Standard form page
   - Implementation time: ~1 day

5. 💡 **Tree Detail Modal** (Nice to Have)
   - Single-tree SPK creation
   - Implementation time: ~0.5 day

---

## 🚨 **8. COMMON PITFALLS & SOLUTIONS**

### **Pitfall 1: Using Fake/Test UUIDs**
❌ **Problem:**
```javascript
const payload = {
  trees: ["tree-id-1", "tree-id-2", "tree-id-3"] // ❌ NOT VALID UUIDs
};
```

✅ **Solution:**
```javascript
// Always fetch real UUIDs from API first
const treesResponse = await fetch('/api/v1/drone/ndre?stress_level=Stres%20Berat');
const trees = await treesResponse.json();
const treeIds = trees.data.map(t => t.id_npokok); // ✅ Real UUIDs

const payload = {
  trees: treeIds // ✅ Valid UUIDs from database
};
```

### **Pitfall 2: No Loading State**
❌ **Problem:** Button clickable during API call → Multiple SPK created

✅ **Solution:**
```javascript
const [isCreating, setIsCreating] = useState(false);

async function createSPK() {
  setIsCreating(true); // Disable button
  try {
    const response = await fetch(...);
    // Handle success
  } finally {
    setIsCreating(false); // Re-enable button
  }
}
```

### **Pitfall 3: No Error Handling**
❌ **Problem:** Silent failure, user confused

✅ **Solution:**
```javascript
try {
  const response = await fetch(...);
  if (!response.ok) {
    throw new Error(await response.text());
  }
} catch (error) {
  // Show user-friendly error
  if (error.message.includes('invalid input syntax for type uuid')) {
    showError('Invalid tree selection. Please refresh and try again.');
  } else {
    showError('Failed to create SPK: ' + error.message);
  }
}
```

### **Pitfall 4: Frontend Caching Issues**
❌ **Problem:** Old data shown after SPK creation

✅ **Solution:**
```javascript
// Add cache-busting headers
const response = await fetch('/api/v1/spk/validasi-drone', {
  method: 'POST',
  headers: {
    'Cache-Control': 'no-cache',
    'Pragma': 'no-cache'
  },
  body: JSON.stringify(payload)
});

// Invalidate cache after successful creation
if (response.ok) {
  await invalidateCache(['spk-list', 'drone-ndre-list']);
  await refreshData();
}
```

---

## 📊 **9. SUCCESS METRICS**

### **Measure UX Success:**

1. **Time to Create SPK:** < 30 seconds (from selection to submit)
2. **Error Rate:** < 5% failed API calls
3. **User Adoption:** 80% users prefer quick action buttons over menu navigation
4. **Task Completion Rate:** 95% users successfully create SPK on first attempt

### **Analytics Events to Track:**

```javascript
// Track user behavior
trackEvent('spk_create_initiated', {
  source: 'drone_ndre_page', // or 'confusion_matrix', 'dashboard', 'menu'
  tree_count: selectedTrees.length,
  priority: selectedPriority
});

trackEvent('spk_create_success', {
  source: 'drone_ndre_page',
  spk_id: createdSPK.id,
  time_to_create: Date.now() - startTime
});

trackEvent('spk_create_failed', {
  source: 'drone_ndre_page',
  error_type: error.type,
  error_message: error.message
});
```

---

## 🎬 **10. QUICK START CHECKLIST**

### **Phase 1: Minimum Viable Product (MVP)**
- [ ] Create button di Drone NDRE Analysis page
- [ ] Selection-based create (checkbox + FAB)
- [ ] Modal dialog dengan Mandor selection
- [ ] API integration dengan error handling
- [ ] Success toast + redirect
- [ ] Loading state + disable button during submit

**Timeline:** 2-3 days  
**Effort:** 1 frontend developer

### **Phase 2: Enhanced UX**
- [ ] Filter-based create SPK
- [ ] Confusion Matrix quick actions
- [ ] Dashboard alert widgets
- [ ] Validation improvements
- [ ] Responsive mobile design

**Timeline:** 1-2 days  
**Effort:** 1 frontend developer

### **Phase 3: Advanced Features**
- [ ] Bulk actions (100+ trees)
- [ ] Tree detail modal integration
- [ ] Analytics tracking
- [ ] A/B testing button placements
- [ ] Keyboard shortcuts (Ctrl+N for new SPK)

**Timeline:** 1 day  
**Effort:** 1 frontend developer

---

## 📚 **11. ADDITIONAL RESOURCES**

### **API Documentation:**
- [Drone NDRE API Guide](./DRONE_NDRE_API_GUIDE.md)
- [SPK Validasi Drone API Guide](./API_SPK_VALIDASI_DRONE_GUIDE.md)
- [Frontend Caching Issue](./FRONTEND_CACHING_ISSUE.md)

### **Related Endpoints:**
```javascript
// Get tree list with NDRE data
GET /api/v1/drone/ndre?stress_level=Stres%20Berat&limit=50

// Get NDRE statistics
GET /api/v1/drone/ndre/statistics

// Get confusion matrix (for FP/FN trees)
GET /api/v1/validation/confusion-matrix

// Create SPK
POST /api/v1/spk/validasi-drone

// Get mandor list
GET /api/v1/users?role=MANDOR

// Get SPK detail
GET /api/v1/spk/:spk_id
```

### **Sample Code Repositories:**
- React/TypeScript: `examples/react-create-spk/`
- Vue.js: `examples/vue-create-spk/`
- Flutter/Dart: `examples/flutter-create-spk/`

---

## 💡 **12. FINAL TIPS**

1. **Start Simple:** Implement basic flow first (selection → modal → submit)
2. **Test with Real Data:** Always use actual UUIDs from database
3. **Handle Errors Gracefully:** Network failures happen, plan for them
4. **Get User Feedback:** A/B test button placements with real Asisten Managers
5. **Iterate Fast:** Ship MVP → Gather feedback → Improve

---

**Questions? Contact Backend Team:**
- API Issues: backend-team@example.com
- Integration Help: Check `docs/TROUBLESHOOTING.md`

**Good luck! 🚀**
