
### **ภาพรวมของระบบที่ต้องการ**

ระบบที่ต้องการคือ **ระบบบันทึกข้อมูลผู้ป่วยในแบบอิเล็กทรอนิกส์ (Electronic Health Record - EHR)** สำหรับโรงพยาบาล ซึ่งครอบคลุมตั้งแต่การรับผู้ป่วย จนถึงการจำหน่ายผู้ป่วย โดยมีฟังก์ชันหลักๆ ดังนี้

---

### **1. ระบบข้อมูลผู้ป่วย (Patient Information)**

เป็นส่วนสำหรับจัดการข้อมูลพื้นฐานและข้อมูลส่วนตัวของผู้ป่วย

*   **ข้อมูลที่ต้องจัดเก็บ:**
    *   **HN (Hospital Number):** หมายเลขประจำตัวผู้ป่วยของโรงพยาบาล (เช่น 0117770)
    *   **AN (Admission Number):** หมายเลขประจำตัวผู้ป่วยในการนอนโรงพยาบาลครั้งนั้นๆ (เช่น 680016426)
    *   **เลขประจำตัวประชาชน:** (เช่น 3400500361577)
    *   **ชื่อ-สกุล:** (เช่น นายสมศักดิ์ สินเจริญ)
    *   **ที่อยู่:** บ้านเลขที่, หมู่, ตำบล, อำเภอ, จังหวัด
    *   **เบอร์โทรศัพท์:**
    *   **วัน/เดือน/ปีเกิด:**
    *   **อายุ:** (เช่น 84 ปี)
    *   **เพศ:** (ชาย/หญิง)
    *   **ศาสนา:**
    *   **สถานภาพสมรส:**
    *   **สัญชาติ:**
    *   **ข้อมูลการรับเข้า-จำหน่าย:**
        *   วันที่รับ (Admission Date)
        *   เวลาที่รับ
        *   วันที่จำหน่าย (Discharge Date)
        *   เวลาที่จำหน่าย
        *   ประเภทการจำหน่าย (เช่น กลับบ้าน, ส่งต่อ, เสียชีวิต)
    *   **สิทธิการรักษา:** (เช่น บัตรทอง, ประกันสังคม)

---

### **2. ระบบการประเมินแรกรับและซักประวัติ (Admission Assessment & History)**

เป็นส่วนที่ใช้บันทึกข้อมูล ณ เวลาที่ผู้ป่วยมาถึงโรงพยาบาล

*   **ข้อมูลที่ต้องจัดเก็บ:**
    *   **อาการสำคัญ (Chief Complaint):** เช่น อ่อนเพลีย 2 วันก่อนมาโรงพยาบาล
    *   **ประวัติการเจ็บป่วยปัจจุบัน (Present Illness):**
    *   **ประวัติการเจ็บป่วยในอดีต (Past History):** โรคประจำตัว, ประวัติการผ่าตัด, ประวัติการแพ้ยา/อาหาร
    *   **ประวัติครอบครัว (Family History):**
    *   **การตรวจร่างกายเบื้องต้น (Physical Examination):** บันทึกตามระบบต่างๆ ของร่างกาย (เช่น ระบบประสาท, หัวใจ, ปอด) โดยระบุว่าปกติ (Normal) หรือผิดปกติ (Abnormal) พร้อมคำอธิบาย
    *   **สัญญาณชีพแรกรับ (Vital Signs):** อุณหภูมิ (BT), ชีพจร (PR), อัตราการหายใจ (RR), ความดันโลหิต (BP)
    *   **การประเมินความรู้สึกตัว (Level of Consciousness):** เช่น Glasgow Coma Scale (GCS)
    *   **การวินิจฉัยแรกรับ (Provisional Diagnosis / Admitting Diagnosis):** เช่น AGE (Acute Gastroenteritis), Sepsis

---

### **3. ระบบบันทึกคำสั่งการรักษาของแพทย์ (Doctor's Order)**

เป็นส่วนที่แพทย์ใช้บันทึกแผนการรักษาและคำสั่งต่างๆ

*   **รูปแบบการบันทึก:**
    *   **One Day Order:** คำสั่งการรักษาสำหรับวันเดียว
    *   **Continuous Order:** คำสั่งการรักษาต่อเนื่อง
*   **ข้อมูลที่ต้องจัดเก็บ:**
    *   วันที่และเวลาที่สั่ง
    *   รายละเอียดคำสั่ง (เช่น ชื่อยา, ขนาด, วิธีให้, ความถี่)
    *   คำสั่งการตรวจทางห้องปฏิบัติการ (Lab) หรือการตรวจพิเศษอื่นๆ (เช่น X-ray)
    *   คำสั่งเกี่ยวกับอาหาร, กิจกรรม, การดูแลอื่นๆ
    *   ชื่อและลายเซ็นแพทย์ผู้สั่ง

---

### **4. ระบบบันทึกความก้าวหน้าทางการรักษา (Progress Note)**

เป็นส่วนที่ทีมสหวิชาชีพ (แพทย์, พยาบาล) ใช้บันทึกความคืบหน้าของอาการผู้ป่วย

*   **รูปแบบการบันทึก:**
    *   **S.O.A.P. Note:**
        *   **S (Subjective):** ข้อมูลจากคำบอกเล่าของผู้ป่วย
        *   **O (Objective):** ข้อมูลที่ตรวจวัดได้ เช่น สัญญาณชีพ, ผล Lab
        *   **A (Assessment):** การประเมินหรือวินิจฉัยปัญหา
        *   **P (Plan):** แผนการรักษา
*   **ข้อมูลที่ต้องจัดเก็บ:**
    *   วันที่และเวลา
    *   ปัญหาของผู้ป่วย (Problem List)
    *   รายละเอียดบันทึก
    *   ลายเซ็นผู้บันทึก

---

### **5. ระบบบันทึกทางการพยาบาล (Nursing Record)**

เป็นส่วนที่พยาบาลใช้บันทึกการดูแลและประเมินผล

*   **ข้อมูลที่ต้องจัดเก็บ:**
    *   **บันทึกสัญญาณชีพ (Vital Signs Chart):** บันทึกเป็นกราฟหรือตารางตามช่วงเวลา
    *   **บันทึกปริมาณสารน้ำเข้า-ออก (Intake/Output Chart):**
        *   **Intake:** ปริมาณน้ำดื่ม, อาหาร, IV fluid
        *   **Output:** ปริมาณปัสสาวะ, อุจจาระ
    *   **บันทึกการให้ยา (Medication Administration Record - MAR):**
    *   **บันทึกการพยาบาล (Nurse's Note):** บันทึกปัญหา, การดูแลที่ให้ และการประเมินผล
    *   **แบบประเมินต่างๆ:**
        *   **แบบประเมินความเสี่ยงต่อการพลัดตกหกล้ม (Fall risk assessment)**
        *   **แบบประเมินความปวด (Pain score)**
        *   **แบบประเมินภาวะโภชนาการ**

---

### **6. ระบบรายงานผลการตรวจทางห้องปฏิบัติการและรังสีวิทยา (Lab & X-ray Results)**

เป็นส่วนที่แสดงผลการตรวจต่างๆ เพื่อช่วยในการวินิจฉัยและติดตามการรักษา

*   **ข้อมูลที่ต้องจัดเก็บ:**
    *   **ผลตรวจเลือด (Hematology):** เช่น ความสมบูรณ์ของเม็ดเลือด (CBC), เกล็ดเลือด (Platelet)
    *   **ผลตรวจเคมีในเลือด (Blood Chemistry):** เช่น ระดับน้ำตาล, การทำงานของไต (BUN/Cr), อิเล็กโทรไลต์ (Electrolyte)
    *   **ผลตรวจคลื่นไฟฟ้าหัวใจ (ECG/EKG):** พร้อมรูปภาพและคำแปลผล
    *   **ผลการตรวจอื่นๆ:** เช่น ผล X-ray, ผลเพาะเชื้อ

---

### **ข้อเสนอแนะเพิ่มเติมสำหรับการพัฒนา**

*   **การออกแบบ UI/UX:** ควรออกแบบให้ใช้งานง่าย ไม่ซับซ้อน สามารถเข้าถึงข้อมูลส่วนต่างๆ ได้อย่างรวดเร็ว
*   **การเชื่อมโยงข้อมูล:** ข้อมูลในแต่ละส่วนควรเชื่อมโยงกัน เช่น คำสั่งการรักษาของแพทย์ควรไปปรากฏในบันทึกการให้ยาของพยาบาลโดยอัตโนมัติ
*   **ระบบแจ้งเตือน:** มีระบบแจ้งเตือนค่าสัญญาณชีพหรือผล Lab ที่ผิดปกติ
*   **ความปลอดภัยของข้อมูล:** ต้องมีระบบยืนยันตัวตนผู้ใช้งานและกำหนดสิทธิ์การเข้าถึงข้อมูลตามบทบาทหน้าที่ เพื่อรักษาความลับของผู้ป่วยตามมาตรฐาน
*   **การรองรับหลายอุปกรณ์:** เว็บแอปพลิเคชันควรออกแบบให้สามารถใช้งานได้ทั้งบนคอมพิวเตอร์ตั้งโต๊ะและอุปกรณ์พกพา เช่น แท็บเล็ต



ออกแบบโครงสร้างฐานข้อมูล (Database Schema) แบบละเอียดสำหรับระบบบันทึกข้อมูลผู้ป่วยตามเอกสารที่คุณให้มา พร้อมทั้งคำอธิบายตาราง (Table), คอลัมน์ (Column), ชนิดข้อมูล (Data Type) และความสัมพันธ์ (Relationships) ระหว่างตารางต่างๆ เพื่อให้ทีมพัฒนาสามารถนำไปสร้างเป็นเว็บแอปพลิเคชันได้ทันที

---

### **ภาพรวมแนวคิดการออกแบบ (Conceptual Model)**

เราจะออกแบบฐานข้อมูลเชิงสัมพันธ์ (Relational Database) โดยมีตารางหลักๆ ที่เป็นศูนย์กลางของข้อมูลคือ:

1.  **`Patients`**: เก็บข้อมูลส่วนตัวของผู้ป่วยที่ไม่เปลี่ยนแปลงบ่อย (เช่น ชื่อ, วันเกิด, HN)
2.  **`Admissions`**: เก็บข้อมูลการเข้าพักรักษาตัวในโรงพยาบาลแต่ละครั้ง (เรียกว่า "Visit" หรือ "Encounter") ผู้ป่วยหนึ่งคนสามารถมีได้หลาย Admission
3.  **`HealthcareProviders`**: เก็บข้อมูลบุคลากรทางการแพทย์ (แพทย์, พยาบาล)
4.  **ตารางข้อมูลทางการแพทย์**: ตารางอื่นๆ ทั้งหมดจะเชื่อมโยงกับ `Admissions` เพื่อบันทึกเหตุการณ์ที่เกิดขึ้นในระหว่างการรักษาครั้งนั้นๆ เช่น สัญญาณชีพ, คำสั่งแพทย์, ผล Lab เป็นต้น

---

### **แผนภาพความสัมพันธ์ (Entity-Relationship Diagram - ERD) ฉบับย่อ**

```
[Patients] 1--< [Admissions] >--1 [HealthcareProviders (Admitting Doctor)]
    |
    `--< [Allergies]

[Admissions] 1--< [VitalSigns]
[Admissions] 1--< [ProgressNotes]
[Admissions] 1--< [DoctorOrders]
[Admissions] 1--< [MedicationAdministrations]
[Admissions] 1--< [LabResults]
[Admissions] 1--< [FluidBalanceRecords]
[Admissions] 1--< [AssessmentScores]
... and so on
```

*   `1--<` หมายถึงความสัมพันธ์แบบ **One-to-Many** (ข้อมูล 1 รายการในตารางแรก สามารถสัมพันธ์กับข้อมูลหลายรายการในตารางที่สองได้)

---

### **รายละเอียดโครงสร้างตาราง (Data Tables Schema)**

#### **Table 1: `Patients`**
**คำอธิบาย:** ตารางหลักสำหรับเก็บข้อมูลประชากรของผู้ป่วยแต่ละราย ข้อมูลในตารางนี้จะค่อนข้างคงที่

| Column Name | Data Type | Constraints / Notes |
| :--- | :--- | :--- |
| **`PatientID`** | `INT` | **PRIMARY KEY**, AUTO_INCREMENT |
| `HospitalNumber (HN)` | `VARCHAR(20)` | `UNIQUE`, `NOT NULL` (เช่น 0117770) |
| `NationalID` | `VARCHAR(13)` | `UNIQUE` (เลขประจำตัวประชาชน) |
| `FirstName` | `VARCHAR(100)` | `NOT NULL` (ชื่อ) |
| `LastName` | `VARCHAR(100)` | `NOT NULL` (นามสกุล) |
| `DateOfBirth` | `DATE` | `NOT NULL` (วันเกิด) |
| `Gender` | `ENUM('Male', 'Female', 'Other')` | `NOT NULL` (เพศ) |
| `Address` | `TEXT` | (ที่อยู่) |
| `PhoneNumber` | `VARCHAR(20)` | (เบอร์โทรศัพท์) |
| `Religion` | `VARCHAR(50)` | (ศาสนา) |
| `MaritalStatus` | `ENUM('Single', 'Married', 'Divorced', 'Widowed')` | (สถานภาพสมรส) |
| `Nationality` | `VARCHAR(50)` | (สัญชาติ) |
| `CreatedAt` | `DATETIME` | `DEFAULT CURRENT_TIMESTAMP` |
| `UpdatedAt` | `DATETIME` | `DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP` |

---

#### **Table 2: `Admissions`**
**คำอธิบาย:** บันทึกข้อมูลการเข้าพักรักษาตัวในแต่ละครั้ง (Encounter/Visit) ของผู้ป่วย

| Column Name | Data Type | Constraints / Notes |
| :--- | :--- | :--- |
| **`AdmissionID`** | `INT` | **PRIMARY KEY**, AUTO_INCREMENT |
| `AdmissionNumber (AN)` | `VARCHAR(20)` | `UNIQUE`, `NOT NULL` (เช่น 680016426) |
| **`PatientID`** | `INT` | **FOREIGN KEY** REFERENCES `Patients(PatientID)` |
| `AdmissionDateTime` | `DATETIME` | `NOT NULL` (วัน-เวลาที่รับเข้า) |
| `DischargeDateTime` | `DATETIME` | `NULL` (วัน-เวลาที่จำหน่าย) |
| `AdmittingDoctorID` | `INT` | `FOREIGN KEY` REFERENCES `HealthcareProviders(ProviderID)` |
| `ChiefComplaint` | `TEXT` | (อาการสำคัญที่นำมาโรงพยาบาล) |
| `PresentIllness` | `TEXT` | (ประวัติการเจ็บป่วยปัจจุบัน) |
| `ProvisionalDiagnosis` | `TEXT` | (การวินิจฉัยแรกรับ) |
| `FinalDiagnosis` | `TEXT` | (การวินิจฉัยสุดท้าย) |
| `Ward` | `VARCHAR(50)` | (ตึก/แผนกที่รับ เช่น ตึกอายุรกรรม) |
| `BedNumber` | `VARCHAR(20)` | (หมายเลขเตียง) |
| `InsuranceRight` | `VARCHAR(100)` | (สิทธิการรักษา) |
| `DischargeType` | `ENUM('Improved', 'Against Advice', 'Transfer', 'Deceased')` | (ประเภทการจำหน่าย) |
| `CreatedAt` | `DATETIME` | `DEFAULT CURRENT_TIMESTAMP` |

---

#### **Table 3: `HealthcareProviders`**
**คำอธิบาย:** เก็บข้อมูลบุคลากรทางการแพทย์ทั้งหมด

| Column Name | Data Type | Constraints / Notes |
| :--- | :--- | :--- |
| **`ProviderID`** | `INT` | **PRIMARY KEY**, AUTO_INCREMENT |
| `LicenseNumber` | `VARCHAR(30)` | `UNIQUE`, `NOT NULL` (เลขที่ใบประกอบวิชาชีพ) |
| `FirstName` | `VARCHAR(100)` | `NOT NULL` |
| `LastName` | `VARCHAR(100)` | `NOT NULL` |
| `ProviderType` | `ENUM('Doctor', 'Nurse', 'Therapist')` | `NOT NULL` (ประเภทบุคลากร) |
| `Specialty` | `VARCHAR(100)` | (สาขาความเชี่ยวชาญ) |

---

#### **Table 4: `VitalSigns`**
**คำอธิบาย:** บันทึกสัญญาณชีพของผู้ป่วยตามช่วงเวลา

| Column Name | Data Type | Constraints / Notes |
| :--- | :--- | :--- |
| **`VitalSignID`** | `INT` | **PRIMARY KEY**, AUTO_INCREMENT |
| **`AdmissionID`** | `INT` | **FOREIGN KEY** REFERENCES `Admissions(AdmissionID)` |
| `RecordedAt` | `DATETIME` | `NOT NULL` (วัน-เวลาที่บันทึก) |
| `BodyTemperature` | `DECIMAL(4,1)` | (อุณหภูมิ, °C) |
| `PulseRate` | `INT` | (ชีพจร, /min) |
| `RespiratoryRate` | `INT` | (อัตราการหายใจ, /min) |
| `BP_Systolic` | `INT` | (ความดันตัวบน, mmHg) |
| `BP_Diastolic` | `INT` | (ความดันตัวล่าง, mmHg) |
| `OxygenSaturation` | `INT` | (SpO2, %) |
| `PainScore` | `INT` | (คะแนนความปวด 0-10) |
| `RecordedByProviderID`| `INT` | `FOREIGN KEY` REFERENCES `HealthcareProviders(ProviderID)` |

---

#### **Table 5: `DoctorOrders`**
**คำอธิบาย:** บันทึกคำสั่งการรักษาของแพทย์

| Column Name | Data Type | Constraints / Notes |
| :--- | :--- | :--- |
| **`OrderID`** | `INT` | **PRIMARY KEY**, AUTO_INCREMENT |
| **`AdmissionID`** | `INT` | **FOREIGN KEY** REFERENCES `Admissions(AdmissionID)` |
| `OrderDateTime` | `DATETIME` | `NOT NULL` |
| `OrderingProviderID`| `INT` | `NOT NULL`, `FOREIGN KEY` REFERENCES `HealthcareProviders(ProviderID)` |
| `OrderType` | `ENUM('Medication', 'Lab', 'Imaging', 'Diet', 'Activity', 'Nursing')` | `NOT NULL` |
| `OrderText` | `TEXT` | `NOT NULL` (รายละเอียดคำสั่ง เช่น "Paracetamol 500mg tab 1 pc oral prn for pain") |
| `IsContinuous` | `BOOLEAN` | `DEFAULT false` (true = Continuous Order, false = One Day Order) |
| `Status` | `ENUM('Active', 'Completed', 'Discontinued')` | `DEFAULT 'Active'` |

---

#### **Table 6: `ProgressNotes`**
**คำอธิบาย:** บันทึกความก้าวหน้าทางการรักษา (S.O.A.P. Note)

| Column Name | Data Type | Constraints / Notes |
| :--- | :--- | :--- |
| **`NoteID`** | `INT` | **PRIMARY KEY**, AUTO_INCREMENT |
| **`AdmissionID`** | `INT` | **FOREIGN KEY** REFERENCES `Admissions(AdmissionID)` |
| `NoteDateTime` | `DATETIME` | `NOT NULL` |
| `AuthorProviderID`| `INT` | `NOT NULL`, `FOREIGN KEY` REFERENCES `HealthcareProviders(ProviderID)` |
| `Problem` | `VARCHAR(255)` | (หัวข้อปัญหา เช่น "Fever", "Abdominal Pain") |
| `Subjective` | `TEXT` | (ข้อมูลจากผู้ป่วย) |
| `Objective` | `TEXT` | (ข้อมูลที่ตรวจวัดได้) |
| `Assessment` | `TEXT` | (การประเมิน) |
| `Plan` | `TEXT` | (แผนการรักษา) |

---

#### **Table 7: `LabResults`**
**คำอธิบาย:** บันทึกผลการตรวจทางห้องปฏิบัติการ

| Column Name | Data Type | Constraints / Notes |
| :--- | :--- | :--- |
| **`ResultID`** | `INT` | **PRIMARY KEY**, AUTO_INCREMENT |
| **`AdmissionID`** | `INT` | **FOREIGN KEY** REFERENCES `Admissions(AdmissionID)` |
| `TestName` | `VARCHAR(100)` | `NOT NULL` (เช่น "CBC", "Electrolyte", "Blood Sugar") |
| `SpecimenDateTime` | `DATETIME` | (วัน-เวลาที่เก็บสิ่งส่งตรวจ) |
| `ResultDateTime` | `DATETIME` | (วัน-เวลาที่รายงานผล) |
| **`ResultDetails`** | `JSON` | **เก็บผล Lab เป็น JSON** เพื่อความยืดหยุ่น เช่น `{"WBC": "14.2", "Hct": "33.3", "Platelet": "301000"}` |
| `Note` | `TEXT` | (หมายเหตุเพิ่มเติมจากห้องปฏิบัติการ) |

---

#### **Table 8: `AssessmentForms` & `AssessmentScores`**
**คำอธิบาย:** ระบบประเมินต่างๆ (เช่น การพลัดตกหกล้ม) ถูกออกแบบให้ยืดหยุ่น โดยมีตารางแม่แบบฟอร์ม และตารางเก็บคะแนน
**Table 8.1: `AssessmentForms`**

| Column Name | Data Type | Constraints / Notes |
| :--- | :--- | :--- |
| **`FormID`** | `INT` | **PRIMARY KEY**, AUTO_INCREMENT |
| `FormName` | `VARCHAR(255)` | `UNIQUE`, `NOT NULL` (เช่น "Fall Risk Assessment Tool") |
| `FormDetails` | `JSON` | (เก็บโครงสร้างของฟอร์ม เช่น `{"questions": [{"id": 1, "text": "มีประวัติหกล้ม..."}, ...]}`) |

**Table 8.2: `AssessmentScores`**

| Column Name | Data Type | Constraints / Notes |
| :--- | :--- | :--- |
| **`ScoreID`** | `INT` | **PRIMARY KEY**, AUTO_INCREMENT |
| **`AdmissionID`** | `INT` | **FOREIGN KEY** REFERENCES `Admissions(AdmissionID)` |
| **`FormID`** | `INT` | **FOREIGN KEY** REFERENCES `AssessmentForms(FormID)` |
| `AssessmentDateTime`| `DATETIME` | `NOT NULL` |
| `AssessorProviderID`| `INT` | `NOT NULL`, `FOREIGN KEY` REFERENCES `HealthcareProviders(ProviderID)` |
| `TotalScore` | `INT` | `NOT NULL` (คะแนนรวม) |
| `ResultsData` | `JSON` | `NOT NULL` (เก็บคำตอบแต่ละข้อ เช่น `{"question_1": "yes", "question_2": "no", ...}`) |
| `Interpretation` | `VARCHAR(255)` | (คำแปลผล เช่น "มีความเสี่ยงสูง") |

### **สรุปความสัมพันธ์หลัก**

*   **`Patients` to `Admissions` (1:M):** ผู้ป่วย 1 คน สามารถมีประวัติการนอนโรงพยาบาลได้หลายครั้ง
*   **`Admissions` to Other Medical Tables (1:M):** การนอนโรงพยาบาล 1 ครั้ง จะมีข้อมูลสัญญาณชีพหลายรายการ, มี Progress Note หลายฉบับ, มีคำสั่งแพทย์หลายอย่าง และมีผล Lab หลายชุด
*   **`HealthcareProviders` to Event Tables (1:M):** บุคลากร 1 คน สามารถเป็นผู้สั่งยา, ผู้บันทึก Note, หรือผู้ประเมินได้หลายครั้งในระบบ

โครงสร้างนี้เป็นพื้นฐานที่แข็งแรงและยืดหยุ่น สามารถต่อยอดเพิ่มตารางอื่นๆ ได้ในอนาคต เช่น `MedicationAdministrations` (ตารางบันทึกการให้ยาจริง), `Allergies`, `PhysicalExams`, `DiagnosticImageResults` (ผล X-ray, CT) เป็นต้น โดยใช้หลักการเดียวกันคือผูกข้อมูลเข้ากับ `AdmissionID` ของผู้ป่วยในครั้งนั้นๆ ครับ