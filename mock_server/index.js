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
  { starttime: "2025-07-01 09:00", endtime: "2025-07-01 10:00", title: "General Checkup", code_Background: "B001", code_Top: "L001" },
  { starttime: "2025-07-03 10:00", endtime: "2025-07-03 11:00", title: "Follow-up", code_Background: "B002", code_Top: "L001" },
  { starttime: "2025-07-05 14:00", endtime: "2025-07-05 15:00", title: "Vaccination", code_Background: "B003", code_Top: "L002" },
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
// START SERVER
// ──────────────────────────────────────────────

app.listen(PORT, () => {
  console.log(`
╔══════════════════════════════════════════════╗
║        He Clinic Mock API Server            ║
║──────────────────────────────────────────────║
║  Medical Apps API  : http://localhost:${PORT}/api  ║
║  Platom API        : http://localhost:${PORT}/platom║
║  WordPress API     : http://localhost:${PORT}/wp-json║
║──────────────────────────────────────────────║
║  Login phone      : 0123456789              ║
║  Login password   : any (e.g. test123)      ║
╚══════════════════════════════════════════════╝`);
});
