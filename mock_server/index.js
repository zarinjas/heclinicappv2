const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const PORT = 4000;

const MOCK_TOKEN = "mock_token_eyJhbGciOiJIUzI1NiJ9.test";
const MOCK_IDPLATO = "platom_usr_001";

// ──────────────────────────────────────────────
// MEDICAL APPS API — /api/*
// ──────────────────────────────────────────────

app.post("/api/login", (req, res) => {
  const { email, password, fcm_token } = req.body;
  console.log(`[LOGIN] email=${email} password=${password}`);
  if (!email || !password) {
    return res.status(400).json({ status: false, message: "Email/password required", token: null });
  }
  res.json({ status: true, token: MOCK_TOKEN });
});

app.post("/api/register", (req, res) => {
  console.log(`[REGISTER]`, req.body);
  res.json({
    token: MOCK_TOKEN,
    user: { idplato: MOCK_IDPLATO },
  });
});

app.get("/api/profile", (req, res) => {
  console.log(`[PROFILE] auth=${req.headers.authorization}`);
  res.json({
    data: {
      avatar: "",
      name: "Test User",
      nric: "000101-01-0001",
      address: "No 123, Jalan Testing",
      dob: "2000-01-01",
      fcm_token: "mock_fcm_token",
      telephone: "0123456789",
      email: "test@heclinic.com",
      changed: "0",
      idplato: MOCK_IDPLATO,
    },
  });
});

app.get("/api/logout", (req, res) => {
  console.log(`[LOGOUT]`);
  res.json({ message: "Logged out successfully" });
});

app.post("/api/forgot-password", (req, res) => {
  res.json({ message: "Reset code sent" });
});

app.post("/api/verify-reset-code", (req, res) => {
  res.json({ message: "Code verified" });
});

app.post("/api/change-password", (req, res) => {
  res.json({ message: "Password changed" });
});

app.post("/api/change-password-first", (req, res) => {
  const { new_password } = req.body;
  console.log(`[CHANGE_PASSWORD_FIRST]`, new_password);
  res.json({ status: true, message: "Password changed successfully" });
});

app.post("/api/changePasswordforgot", (req, res) => {
  const { telephone } = req.body;
  console.log(`[FORGOT_CHANGE] telephone=${telephone}`);
  res.json({ status: true, message: "Password reset successfully" });
});

app.get("/api/sliders", (req, res) => {
  res.json([
    { id: 1, image: "https://placehold.co/600x400/122560/FFFFFF?text=Slide+1" },
    { id: 2, image: "https://placehold.co/600x400/2563EB/FFFFFF?text=Slide+2" },
    { id: 3, image: "https://placehold.co/600x400/10B981/FFFFFF?text=Slide+3" },
  ]);
});

app.get("/api/servicepackages", (req, res) => {
  res.json([
    { id: 1, name: "Basic Health Check", price: "RM 99", description: "Basic health screening package" },
    { id: 2, name: "Premium Health Check", price: "RM 299", description: "Comprehensive health screening" },
    { id: 3, name: "Heart Package", price: "RM 499", description: "Cardiovascular screening" },
  ]);
});

app.post("/api/appointments", (req, res) => {
  console.log(`[CREATE_APPOINTMENT]`, req.body);
  res.json({ status: true, message: "Appointment created", appointment_id: "apt_001" });
});

app.post("/api/update", (req, res) => {
  console.log(`[UPDATE_PROFILE]`, req.body);
  res.json({
    status: true,
    message: "Profile updated",
    user: { avatar: "", name: "Test User" },
  });
});

app.get("/api/pdfs", (req, res) => {
  res.json({
    data: [
      { path: "/pdfs/mc_001.pdf", created_at: "2025-06-01 10:00:00" },
      { path: "/pdfs/mc_002.pdf", created_at: "2025-06-15 14:00:00" },
    ],
  });
});

// ──────────────────────────────────────────────
// PLATOM API — /platom/*
// ──────────────────────────────────────────────

const mockPatients = [
  { _id: MOCK_IDPLATO, name: "Test User", nric: "000101-01-0001", dob: "2000-01-01", email: "test@heclinic.com", given_id: "G001" },
  { _id: "platom_usr_002", name: "Jane Doe", nric: "000202-02-0002", dob: "1995-05-15", email: "jane@test.com", given_id: "G002" },
];

const mockFacilities = [
  { _id: "fac_001", name: "Dr. Ahmad", nric: "700101-01-0001", dob: "1970-01-01", email: "dr.ahmad@heclinic.com" },
  { _id: "fac_002", name: "Dr. Sarah", nric: "750202-02-0002", dob: "1975-02-02", email: "dr.sarah@heclinic.com" },
  { _id: "fac_003", name: "Dr. Lim", nric: "800303-03-0003", dob: "1980-03-03", email: "dr.lim@heclinic.com" },
];

const mockAppointments = [
  { starttime: "2025-07-01 09:00", endtime: "2025-07-01 10:00", title: "General Checkup", code_Background: "B001", code_Top: "L001", name_Background: "Dr. Ahmad Bin Ismail", name_Top: "He Clinic Shah Alam", status: "confirmed", doctorname: "Dr. Ahmad Bin Ismail", specialty: "General Practitioner", branch_name: "He Clinic Shah Alam", appointment_type: "General Checkup", notes: "Routine checkup" },
  { starttime: "2025-07-03 10:00", endtime: "2025-07-03 11:00", title: "Follow-up", code_Background: "B002", code_Top: "L001", name_Background: "Dr. Sarah Binti Abdullah", name_Top: "He Clinic Shah Alam", status: "confirmed", doctorname: "Dr. Sarah Binti Abdullah", specialty: "Pediatrician", branch_name: "He Clinic Shah Alam", appointment_type: "Follow-up", notes: "Review lab results" },
  { starttime: "2025-07-05 14:00", endtime: "2025-07-05 15:00", title: "Vaccination", code_Background: "B003", code_Top: "L002", name_Background: "Dr. Lim Wei Ming", name_Top: "He Clinic Bangi", status: "pending", doctorname: "Dr. Lim Wei Ming", specialty: "Cardiologist", branch_name: "He Clinic Bangi", appointment_type: "Vaccination", notes: "Flu vaccine" },
];

app.get("/platom/patient", (req, res) => {
  res.json(mockPatients);
});

app.get("/platom/patient/:id", (req, res) => {
  const patient = mockPatients.find((p) => p._id === req.params.id);
  res.json(patient ? [patient] : []);
});

app.get("/platom/search/patient", (req, res) => {
  const { telephone } = req.query;
  console.log(`[SEARCH_PATIENT] telephone=${telephone}`);
  const found = mockPatients.filter((p) => telephone && telephone.endsWith("6789"));
  res.json(found.length > 0 ? found : []);
});

app.put("/platom/patient/:id", (req, res) => {
  console.log(`[UPDATE_PATIENT] id=${req.params.id}`, req.body);
  res.json({ status: true, message: "Patient updated" });
});

app.delete("/platom/patient/:id", (req, res) => {
  console.log(`[DELETE_PATIENT] id=${req.params.id}`);
  res.json({ status: true, message: "Patient deleted" });
});

app.get("/platom/facility", (req, res) => {
  res.json(mockFacilities);
});

app.get("/platom/appointment", (req, res) => {
  const { patient_id, start_date, modified_since } = req.query;
  console.log(`[GET_APPOINTMENT] patient=${patient_id} start=${start_date} modified=${modified_since}`);

  if (modified_since) {
    return res.json([]);
  }
  if (start_date) {
    const upcoming = mockAppointments.filter((a) => a.starttime >= start_date);
    return res.json(upcoming);
  }
  res.json(mockAppointments);
});

app.get("/platom/appointment/codes", (req, res) => {
  res.json({
    Background: {
      codes: [
        { id: "B001", name: "General Checkup" },
        { id: "B002", name: "Specialist" },
        { id: "B003", name: "Vaccination" },
        { id: "B004", name: "Follow-up" },
      ],
    },
    Top: {
      codes: [
        { id: "L001", name: "Main Branch - KL" },
        { id: "L002", name: "Branch - PJ" },
        { id: "L003", name: "Branch - Penang" },
      ],
    },
  });
});

app.get("/platom/appointment/:id", (req, res) => {
  const appointmentId = req.params.id;
  console.log(`[GET_APPOINTMENT_DETAIL] id=${appointmentId}`);
  const detail = {
    starttime: "2025-07-01 09:00",
    endtime: "2025-07-01 10:00",
    title: "General Checkup",
    code_Background: "B001",
    code_Top: "L001",
    name_Background: "Dr. Ahmad Bin Ismail",
    name_Top: "He Clinic Shah Alam",
    status: "confirmed",
    doctorname: "Dr. Ahmad Bin Ismail",
    specialty: "General Practitioner",
    branch_name: "He Clinic Shah Alam",
    appointment_type: "General Checkup",
    notes: "Routine checkup",
    appointment_id: appointmentId,
  };
  res.json([detail]);
});

app.get("/platom/appointments/calendars", (req, res) => {
  res.json(mockAppointments);
});

app.get("/platom/patient/:id/note", (req, res) => {
  console.log(`[GET_REPORT] patient=${req.params.id}`);
  res.json([
    {
      note: "Patient reported mild fever and cough. Prescribed paracetamol.",
      timestamp: "2025-06-15 10:30:00",
      folder_name: "General",
      author: "Dr. Ahmad",
      diagnosis: ["J06.9 - Acute upper respiratory infection"],
      attachments: [],
      cancel: 0,
      draft: 0,
    },
    {
      note: "Follow-up: Symptoms resolved. Patient cleared.",
      timestamp: "2025-06-22 09:00:00",
      folder_name: "Follow-up",
      author: "Dr. Ahmad",
      diagnosis: [],
      attachments: [],
      cancel: 0,
      draft: 0,
    },
  ]);
});

app.get("/platom/letter", (req, res) => {
  const { patient_id } = req.query;
  console.log(`[GET_LETTER] patient=${patient_id}`);
  res.json([
    {
      subject: "Medical Certificate - Sick Leave",
      html: "<p>This is to certify that <b>Test User</b> was under my medical care.</p>",
      created_on: "2025-06-15",
      created_by: "Dr. Ahmad",
    },
  ]);
});

app.get("/platom/invoice", (req, res) => {
  const { patient_id } = req.query;
  console.log(`[GET_INVOICE] patient=${patient_id}`);
  res.json([
    {
      invoice: 1001,
      item: [
        { name: "Paracetamol 500mg", dosage: "1 tab TDS", category: "Medicine", inventory: "INV-001", redemptions: 1, given_id: "G001", invoice_id: "INV-1001-001" },
        { name: "Vitamin C", dosage: "1 tab OD", category: "Supplement", inventory: "INV-002", redemptions: 0, given_id: "G001", invoice_id: "INV-1001-002" },
      ],
    },
    {
      invoice: 1002,
      item: [
        { name: "Amoxicillin", dosage: "500mg TDS", category: "Medicine", inventory: "INV-003", redemptions: 1, given_id: "G001", invoice_id: "INV-1002-001" },
      ],
    },
  ]);
});

// ──────────────────────────────────────────────
// WORDPRESS ARTICLES — /wp-json/wp/v2/*
// ──────────────────────────────────────────────

app.get("/wp-json/wp/v2/posts", (req, res) => {
  const { per_page } = req.query;
  console.log(`[ARTICLES] per_page=${per_page}`);
  res.json([
    {
      id: 1,
      title: { rendered: "5 Tips for a Healthy Heart" },
      excerpt: { rendered: "<p>Maintaining heart health is crucial...</p>" },
      content: { rendered: "<p>Full article about heart health tips for better living.</p>" },
      featured_media_src_url: "https://placehold.co/800x400/EF4444/FFFFFF?text=Heart+Health",
    },
    {
      id: 2,
      title: { rendered: "Understanding Your Blood Test Results" },
      excerpt: { rendered: "<p>Blood tests can reveal a lot about your health...</p>" },
      content: { rendered: "<p>Complete guide to understanding common blood test markers and what they mean.</p>" },
      featured_media_src_url: "https://placehold.co/800x400/3B82F6/FFFFFF?text=Blood+Test",
    },
    {
      id: 3,
      title: { rendered: "When to See a Doctor: Warning Signs" },
      excerpt: { rendered: "<p>Knowing when to seek medical help is important...</p>" },
      content: { rendered: "<p>Warning signs and symptoms that should prompt a visit to your healthcare provider.</p>" },
      featured_media_src_url: "https://placehold.co/800x400/F59E0B/FFFFFF?text=Warning+Signs",
    },
  ]);
});

// ──────────────────────────────────────────────
// LARAVEL CMS API — /api/v2/cms/*
// ──────────────────────────────────────────────

const mockCmsSliders = [
  { id: 1, image: "https://placehold.co/800x400/122560/FFFFFF?text=Promo+1", title: "Health Screening Promo", link_url: "https://heclinic.com/promo1", is_active: true, sort_order: 1 },
  { id: 2, image: "https://placehold.co/800x400/2563EB/FFFFFF?text=Promo+2", title: "Vaccination Drive", link_url: "https://heclinic.com/promo2", is_active: true, sort_order: 2 },
  { id: 3, image: "https://placehold.co/800x400/10B981/FFFFFF?text=New+Service", title: "New Specialist Available", link_url: "https://heclinic.com/promo3", is_active: true, sort_order: 3 },
];

const mockServicePackages = [
  { id: 1, name: "Basic Health Check", description: "Complete blood count, urine analysis, BMI", image: "https://placehold.co/400x300/122560/FFFFFF?text=Basic+Check", is_active: true, sort_order: 1 },
  { id: 2, name: "Premium Health Check", description: "Comprehensive screening including ECG, chest X-ray, blood panel", image: "https://placehold.co/400x300/2563EB/FFFFFF?text=Premium", is_active: true, sort_order: 2 },
  { id: 3, name: "Heart Package", description: "Cardiovascular screening with ECG, echo, stress test", image: "https://placehold.co/400x300/DC2626/FFFFFF?text=Heart", is_active: true, sort_order: 3 },
  { id: 4, name: "Women's Wellness", description: "Mammogram, pap smear, bone density scan", image: "https://placehold.co/400x300/EC4899/FFFFFF?text=Women", is_active: true, sort_order: 4 },
];

const mockCmsArticles = [
  { id: 1, title: "5 Tips for a Healthy Heart", slug: "healthy-heart-tips", body: "<p>Maintaining heart health is crucial for overall well-being. Here are 5 tips to keep your heart healthy: regular exercise, balanced diet, stress management, adequate sleep, and regular check-ups.</p><p>Heart disease is one of the leading causes of death worldwide, but many cases are preventable with lifestyle changes.</p>", excerpt: "Maintaining heart health is crucial for overall well-being...", featured_image: "https://placehold.co/800x400/EF4444/FFFFFF?text=Heart+Health", category: "Health Tips", author_name: "Dr. Ahmad", status: "published", sort_order: 1, published_at: "2025-06-15 08:00:00" },
  { id: 2, title: "Understanding Your Blood Test Results", slug: "blood-test-results", body: "<p>Blood tests can reveal a lot about your health. This guide explains common markers: complete blood count, lipid profile, blood glucose, liver function, and kidney function.</p><p>Understanding your results helps you take proactive steps toward better health.</p>", excerpt: "Blood tests can reveal a lot about your health...", featured_image: "https://placehold.co/800x400/3B82F6/FFFFFF?text=Blood+Test", category: "Education", author_name: "Dr. Sarah", status: "published", sort_order: 2, published_at: "2025-06-10 10:00:00" },
  { id: 3, title: "When to See a Doctor: Warning Signs", slug: "warning-signs", body: "<p>Knowing when to seek medical help is important. Warning signs include: persistent fever, unexplained weight loss, chest pain, shortness of breath, and unusual bleeding.</p><p>Don't ignore these signs — early detection saves lives.</p>", excerpt: "Knowing when to seek medical help is important...", featured_image: "https://placehold.co/800x400/F59E0B/FFFFFF?text=Warning+Signs", category: "Health Tips", author_name: "Dr. Lim", status: "published", sort_order: 3, published_at: "2025-06-05 09:00:00" },
  { id: 4, title: "Vaccination Guide for Adults", slug: "adult-vaccination", body: "<p>Vaccines aren't just for children. Adults need boosters and specific vaccines too: influenza, Tdap, shingles, pneumococcal, and HPV.</p><p>Consult your doctor about which vaccines are right for you based on your age and health conditions.</p>", excerpt: "Vaccines aren't just for children...", featured_image: "https://placehold.co/800x400/8B5CF6/FFFFFF?text=Vaccination", category: "Education", author_name: "Dr. Ahmad", status: "published", sort_order: 4, published_at: "2025-05-28 11:00:00" },
];

const mockCmsVideos = [
  { id: 1, title: "How to Check Your Blood Pressure", tiktok_url: "https://www.tiktok.com/@heclinic/video/1", thumbnail_url: "https://placehold.co/400x720/122560/FFFFFF?text=BP+Check", tiktok_author: "@heclinic", status: "published", sort_order: 1, published_at: "2025-06-20 08:00:00" },
  { id: 2, title: "5-Minute Morning Stretch", tiktok_url: "https://www.tiktok.com/@heclinic/video/2", thumbnail_url: "https://placehold.co/400x720/2563EB/FFFFFF?text=Stretch", tiktok_author: "@heclinic", status: "published", sort_order: 2, published_at: "2025-06-18 09:00:00" },
  { id: 3, title: "Healthy Breakfast Ideas", tiktok_url: "https://www.tiktok.com/@heclinic/video/3", thumbnail_url: "https://placehold.co/400x720/10B981/FFFFFF?text=Breakfast", tiktok_author: "@heclinic", status: "published", sort_order: 3, published_at: "2025-06-15 10:00:00" },
];

const mockBranches = [
  { id: 1, name: "He Clinic Shah Alam", address: "No. 12, Jalan Plumbum P7/P, Seksyen 7, 40000 Shah Alam, Selangor", phone: "+603-5510 1234", whatsapp_number: "+60123456789", image: "https://placehold.co/600x400/122560/FFFFFF?text=Shah+Alam", operating_hours: { monday: "8:00 AM - 5:00 PM", tuesday: "8:00 AM - 5:00 PM", wednesday: "8:00 AM - 5:00 PM", thursday: "8:00 AM - 5:00 PM", friday: "8:00 AM - 5:00 PM", saturday: "8:00 AM - 1:00 PM", sunday: "Closed" }, google_maps_link: "https://maps.google.com/?q=He+Clinic+Shah+Alam", plato_facility_id: "FAC-SA-001", is_active: true },
  { id: 2, name: "He Clinic Bangi", address: "No. 45, Jalan Medan Pusat Bandar 2, Seksyen 9, 43650 Bandar Baru Bangi, Selangor", phone: "+603-8920 5678", whatsapp_number: "+60198765432", image: "https://placehold.co/600x400/2563EB/FFFFFF?text=Bangi", operating_hours: { monday: "8:30 AM - 5:30 PM", tuesday: "8:30 AM - 5:30 PM", wednesday: "8:30 AM - 5:30 PM", thursday: "8:30 AM - 5:30 PM", friday: "8:30 AM - 5:30 PM", saturday: "8:30 AM - 1:00 PM", sunday: "Closed" }, google_maps_link: "https://maps.google.com/?q=He+Clinic+Bangi", plato_facility_id: "FAC-BNG-001", is_active: true },
  { id: 3, name: "He Clinic Putrajaya", address: "Lot 3-15, Jalan P15H, Presint 15, 62000 Putrajaya", phone: "+603-8880 9012", whatsapp_number: "+60111234567", image: "https://placehold.co/600x400/10B981/FFFFFF?text=Putrajaya", operating_hours: { monday: "8:00 AM - 5:00 PM", tuesday: "8:00 AM - 5:00 PM", wednesday: "8:00 AM - 5:00 PM", thursday: "8:00 AM - 5:00 PM", friday: "8:00 AM - 12:30 PM", saturday: "Closed", sunday: "Closed" }, google_maps_link: "https://maps.google.com/?q=He+Clinic+Putrajaya", plato_facility_id: "FAC-PTJ-001", is_active: false },
];

const mockDoctors = [
  { id: 1, name: "Dr. Ahmad Bin Ismail", specialty: "General Practitioner", bio: "Experienced GP with 15 years in family medicine.", photo: "https://placehold.co/200x200/122560/FFFFFF?text=Dr+A", is_visible_in_app: true, branch_id: 1, branch_name: "He Clinic Shah Alam" },
  { id: 2, name: "Dr. Sarah Binti Abdullah", specialty: "Pediatrician", bio: "Specializing in children's health and development.", photo: "https://placehold.co/200x200/2563EB/FFFFFF?text=Dr+S", is_visible_in_app: true, branch_id: 1, branch_name: "He Clinic Shah Alam" },
  { id: 3, name: "Dr. Lim Wei Ming", specialty: "Cardiologist", bio: "Heart health specialist with advanced training in cardiology.", photo: "https://placehold.co/200x200/DC2626/FFFFFF?text=Dr+L", is_visible_in_app: true, branch_id: 2, branch_name: "He Clinic Bangi" },
  { id: 4, name: "Dr. Nurul Huda", specialty: "General Practitioner", bio: "Dedicated to providing comprehensive primary care.", photo: "https://placehold.co/200x200/10B981/FFFFFF?text=Dr+N", is_visible_in_app: true, branch_id: 2, branch_name: "He Clinic Bangi" },
  { id: 5, name: "Dr. Rajesh Kumar", specialty: "Orthopedics", bio: "Bone and joint specialist.", photo: "https://placehold.co/200x200/8B5CF6/FFFFFF?text=Dr+R", is_visible_in_app: false, branch_id: 1, branch_name: "He Clinic Shah Alam" },
];

app.get("/api/v2/cms/sliders", (req, res) => {
  console.log(`[CMS] GET sliders`);
  res.json(mockCmsSliders.filter(s => s.is_active));
});

app.get("/api/v2/cms/service-packages", (req, res) => {
  console.log(`[CMS] GET service-packages`);
  res.json(mockServicePackages.filter(p => p.is_active));
});

app.get("/api/v2/cms/articles", (req, res) => {
  const limit = parseInt(req.query.limit) || 10;
  const page = parseInt(req.query.page) || 1;
  console.log(`[CMS] GET articles page=${page} limit=${limit}`);
  const filtered = mockCmsArticles.filter(a => a.status === 'published');
  const total = filtered.length;
  const lastPage = Math.ceil(total / limit);
  const start = (page - 1) * limit;
  const data = filtered.slice(start, start + limit);
  res.json({ data, total, current_page: page, lastPage, per_page: limit });
});

app.get("/api/v2/cms/articles/:slug", (req, res) => {
  console.log(`[CMS] GET article slug=${req.params.slug}`);
  const article = mockCmsArticles.find(a => a.slug === req.params.slug);
  if (!article) return res.status(404).json({ error: true, message: "Article not found" });
  res.json(article);
});

app.get("/api/v2/cms/videos", (req, res) => {
  const limit = parseInt(req.query.limit) || 10;
  const page = parseInt(req.query.page) || 1;
  console.log(`[CMS] GET videos page=${page} limit=${limit}`);
  const filtered = mockCmsVideos.filter(v => v.status === 'published');
  const total = filtered.length;
  const lastPage = Math.ceil(total / limit);
  const start = (page - 1) * limit;
  const data = filtered.slice(start, start + limit);
  res.json({ data, total, current_page: page, lastPage, per_page: limit });
});

// ──────────────────────────────────────────────
// LARAVEL CONFIG API — /api/v2/config/*
// ──────────────────────────────────────────────

app.get("/api/v2/config/branches", (req, res) => {
  console.log(`[CONFIG] GET branches`);
  res.json(mockBranches.filter(b => b.is_active));
});

app.get("/api/v2/config/doctors", (req, res) => {
  const { branch_id, visible } = req.query;
  console.log(`[CONFIG] GET doctors branch=${branch_id} visible=${visible}`);
  let result = mockDoctors;
  if (branch_id) {
    result = result.filter(d => d.branch_id === parseInt(branch_id));
  }
  if (visible === '1') {
    result = result.filter(d => d.is_visible_in_app);
  }
  res.json(result);
});

// ──────────────────────────────────────────────
// PATIENT DOCUMENTS — /api/v2/patients/*
// ──────────────────────────────────────────────

const mockDocuments = [
  { id: 1, filename: "mc_2025_001.pdf", original_name: "Medical Certificate.pdf", title: "MC - June 2025", mime_type: "application/pdf", size_bytes: 128000, uploaded_by: 1, created_at: "2025-06-15 10:00:00" },
  { id: 2, filename: "lab_result_001.pdf", original_name: "Blood Test Report.pdf", title: "Blood Test - June 2025", mime_type: "application/pdf", size_bytes: 256000, uploaded_by: 1, created_at: "2025-06-10 14:30:00" },
  { id: 3, filename: "xray_chest_001.jpg", original_name: "Chest X-Ray.jpg", title: "Chest X-Ray", mime_type: "image/jpeg", size_bytes: 512000, uploaded_by: 1, created_at: "2025-05-20 09:15:00" },
];

app.get("/api/v2/patients/:id/documents", (req, res) => {
  console.log(`[DOCUMENTS] GET patient=${req.params.id}`);
  res.json(mockDocuments);
});

// ──────────────────────────────────────────────
// PLATO PROXY API — /api/v2/plato/*
// (mirrors the same mock data as /platom/*)
// ──────────────────────────────────────────────

// Health check
app.get("/api/v2/plato/health", (req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

app.get("/api/v2/plato/patient", (req, res) => {
  res.json(mockPatients);
});

app.get("/api/v2/plato/patient/:id", (req, res) => {
  const patient = mockPatients.find(p => p._id === req.params.id);
  res.json(patient ? [patient] : []);
});

app.get("/api/v2/plato/search/patient", (req, res) => {
  const { telephone } = req.query;
  const found = mockPatients.filter(p => telephone && telephone.endsWith("6789"));
  res.json(found.length > 0 ? found : []);
});

app.put("/api/v2/plato/patient/:id", (req, res) => {
  console.log(`[PLATO] PUT patient id=${req.params.id}`);
  res.json({ status: true, message: "Patient updated" });
});

app.delete("/api/v2/plato/patient/:id", (req, res) => {
  console.log(`[PLATO] DELETE patient id=${req.params.id}`);
  res.json({ status: true, message: "Patient deleted" });
});

app.get("/api/v2/plato/facility", (req, res) => {
  res.json(mockFacilities);
});

// Must be BEFORE /api/v2/plato/appointment/:id to avoid matching
app.get("/api/v2/plato/appointment/codes", (req, res) => {
  res.json({
    Background: {
      codes: [
        { id: "B001", name: "General Checkup" },
        { id: "B002", name: "Specialist" },
        { id: "B003", name: "Vaccination" },
        { id: "B004", name: "Follow-up" },
      ],
    },
    Top: {
      codes: [
        { id: "L001", name: "Main Branch - KL" },
        { id: "L002", name: "Branch - PJ" },
        { id: "L003", name: "Branch - Penang" },
      ],
    },
  });
});

app.get("/api/v2/plato/appointments/calendars", (req, res) => {
  res.json(mockAppointments);
});

app.get("/api/v2/plato/appointment", (req, res) => {
  const { patient_id, start_date, modified_since } = req.query;
  if (modified_since) return res.json([]);
  if (start_date) {
    const upcoming = mockAppointments.filter(a => a.starttime >= start_date);
    return res.json(upcoming);
  }
  res.json(mockAppointments);
});

app.get("/api/v2/plato/appointment/:id", (req, res) => {
  const detail = {
    starttime: "2025-07-01 09:00",
    endtime: "2025-07-01 10:00",
    title: "General Checkup",
    code_Background: "B001",
    code_Top: "L001",
    name_Background: "Dr. Ahmad Bin Ismail",
    name_Top: "He Clinic Shah Alam",
    status: "confirmed",
    doctorname: "Dr. Ahmad Bin Ismail",
    specialty: "General Practitioner",
    branch_name: "He Clinic Shah Alam",
    appointment_type: "General Checkup",
    notes: "Routine checkup",
    appointment_id: req.params.id,
  };
  res.json([detail]);
});

app.post("/api/v2/plato/appointment/:id/cancel", (req, res) => {
  console.log(`[PLATO] POST cancel appointment id=${req.params.id}`);
  res.json({ status: true, message: "Appointment cancelled" });
});

app.post("/api/v2/plato/appointment/slots", (req, res) => {
  console.log(`[PLATO] POST appointment slots`, req.body);
  const { month, starttime, endtime } = req.body;
  const [startH, startM] = (starttime || '08:00').split(':').map(Number);
  const [endH, endM] = (endtime || '18:00').split(':').map(Number);
  const slots = [];
  // Generate slots for the first 7 days of the requested month
  for (let d = 1; d <= 7; d++) {
    const dateStr = `${month || '2025-07'}-${String(d).padStart(2, '0')}`;
    for (let h = startH; h < endH; h++) {
      slots.push({ time: `${dateStr}T${String(h).padStart(2, '0')}:00`, available: h !== 12 });
      if (h < endH - 1) {
        slots.push({ time: `${dateStr}T${String(h).padStart(2, '0')}:30`, available: true });
      }
    }
  }
  res.json(slots);
});

app.get("/api/v2/plato/patient/:id/note", (req, res) => {
  res.json([
    {
      note: "Patient reported mild fever and cough. Prescribed paracetamol.",
      timestamp: "2025-06-15 10:30:00",
      folder_name: "General",
      author: "Dr. Ahmad",
      diagnosis: ["J06.9 - Acute upper respiratory infection"],
      attachments: [],
      cancel: 0,
      draft: 0,
    },
    {
      note: "Follow-up: Symptoms resolved. Patient cleared.",
      timestamp: "2025-06-22 09:00:00",
      folder_name: "Follow-up",
      author: "Dr. Ahmad",
      diagnosis: [],
      attachments: [],
      cancel: 0,
      draft: 0,
    },
  ]);
});

app.get("/api/v2/plato/patient/:id/graphing", (req, res) => {
  res.json({
    "Blood Pressure": [
      { date: "2025-06-01", value: "120/80" },
      { date: "2025-06-08", value: "118/78" },
      { date: "2025-06-15", value: "122/82" },
      { date: "2025-06-22", value: "116/76" },
      { date: "2025-06-29", value: "119/79" },
    ],
    "Heart Rate": [
      { date: "2025-06-01", value: "72" },
      { date: "2025-06-08", value: "70" },
      { date: "2025-06-15", value: "74" },
      { date: "2025-06-22", value: "68" },
      { date: "2025-06-29", value: "71" },
    ],
    "Weight": [
      { date: "2025-06-01", value: "70.0" },
      { date: "2025-06-08", value: "69.5" },
      { date: "2025-06-15", value: "69.8" },
      { date: "2025-06-22", value: "69.2" },
      { date: "2025-06-29", value: "69.0" },
    ],
  });
});

app.get("/api/v2/plato/letter", (req, res) => {
  res.json([
    {
      subject: "Medical Certificate - Sick Leave",
      html: "<p>This is to certify that <b>Test User</b> was under my medical care.</p>",
      created_on: "2025-06-15",
      created_by: "Dr. Ahmad",
    },
  ]);
});

app.get("/api/v2/plato/invoice", (req, res) => {
  res.json([
    {
      invoice: 1001,
      item: [
        { name: "Paracetamol 500mg", dosage: "1 tab TDS", category: "Medicine", inventory: "INV-001", redemptions: 1, given_id: "G001", invoice_id: "INV-1001-001" },
        { name: "Vitamin C", dosage: "1 tab OD", category: "Supplement", inventory: "INV-002", redemptions: 0, given_id: "G001", invoice_id: "INV-1001-002" },
      ],
    },
    {
      invoice: 1002,
      item: [
        { name: "Amoxicillin", dosage: "500mg TDS", category: "Medicine", inventory: "INV-003", redemptions: 1, given_id: "G001", invoice_id: "INV-1002-001" },
      ],
    },
  ]);
});

app.get("/api/v2/plato/queue/status", (req, res) => {
  res.json({
    queue_number: "Q025",
    patient_name: "Test User",
    status: "waiting",
    estimated_wait: "15 minutes",
    current_serving: "Q020",
  });
});

app.get("/api/v2/plato/payment", (req, res) => {
  res.json({
    data: [
      { id: 1, invoice_no: "INV-1001", amount: 150.00, date: "2025-06-15", status: "paid", description: "General consultation" },
      { id: 2, invoice_no: "INV-1002", amount: 85.50, date: "2025-06-10", status: "paid", description: "Lab test" },
      { id: 3, invoice_no: "INV-1003", amount: 250.00, date: "2025-05-28", status: "unpaid", description: "Health screening" },
    ],
    current_page: 1,
    total: 3,
    last_page: 1,
  });
});

// Admin appointment sync endpoint
app.post("/api/v2/admin/appointments", (req, res) => {
  console.log(`[ADMIN] POST appointment`, req.body);
  res.json({ success: true, message: "Appointment synced successfully.", plato_appointment_id: "apt_mock_001" });
});

// ──────────────────────────────────────────────
// START SERVER
// ──────────────────────────────────────────────

app.listen(PORT, () => {
  console.log(`
╔══════════════════════════════════════════════╗
║        He Clinic Mock API Server            ║
║──────────────────────────────────────────────║
║  Medical Apps API  : http://localhost:${PORT}/api  ║
║  Laravel CMS API   : http://localhost:${PORT}/api/v2║
║  Plato API         : http://localhost:${PORT}/api/v2/plato║
║  WordPress API     : http://localhost:${PORT}/wp-json║
║──────────────────────────────────────────────║
║  Login phone      : 0123456789              ║
║  Login password   : any (e.g. test123)      ║
╚══════════════════════════════════════════════╝`);
});
