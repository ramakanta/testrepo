# Financial Crime Investigation — Deep Research Report & Agentic Blueprint

*Prepared as a foundation for building an agentic, conversational AML-investigation product with grounded, SOP-anchored reasoning. Scope: EU (esp. Dutch) and US bank financial-crime identification & investigation.*

---

## 0. How this maps to your deck

Your deck frames the opportunity as **Prevention → Detection → Remediation**, and correctly identifies **Investigation** (inside Remediation) as the white space. The strategic challenges you list — *Customer Inertia*, the *"Data Visa" Bottleneck*, and the *Non-Agentic Product* charter gap — are all real and confirmed by this research:

- **"Data Visa" bottleneck is the #1 structural blocker**, not a one-off HSBC quirk. Data residency/sovereignty (GDPR in the EU) + per-version model-approval governance are the gating constraints on *any* GenAI in a bank. Solve this first or nothing ships. (§7)
- **The "Non-Agentic Product" charter gap is actually your moat.** The flagship deployed system (Google AML AI / HSBC DRA) is a *supervised-ML risk-scoring* engine — it replaces rules, but it is **not** agentic investigation. Detection is getting crowded; **conversational, grounded investigation is genuinely under-served.** (§5, §6)
- **Your "Generative XAI / Investigation Cue" concept is directionally right** but needs hardening: feature attributions (SHAP) are *unstable on retraining* and must be treated as investigation *cues*, never as exact model reasoning or as grounded fact. (§6.3)

---

## 1. The financial-crime operating model (the spine)

US and EU banks run materially the same operational spine; the regulatory labels differ. The authoritative US structure is the **FFIEC BSA/AML Examination Manual, Appendix S**, which defines five suspicious-activity-monitoring components — and the operational workflow maps directly onto them:

| FFIEC component | Operational stage |
|---|---|
| 1. Identification / alert of unusual activity | Transaction monitoring → alert generation |
| 2. Managing alerts | L1 triage / disposition |
| 3. SAR decision-making | L2/L3 investigation → file/no-file decision |
| 4. SAR completion and filing | Narrative drafting + filing |
| 5. Monitoring & filing on continuing activity | Continuing-activity SAR loop |

*Source: FFIEC Appendix S — https://bsaaml.ffiec.gov/manual/Appendices/20 (HIGH confidence).*

---

## 2. Regulatory SOP anchors (the grounding corpus)

These are the documents an agentic product must ground its reasoning in. **This list is effectively your RAG corpus.**

### 2.1 United States

| Anchor | What it pins down | Confidence |
|---|---|---|
| **BSA + USA PATRIOT Act / 31 CFR 1020.210** | The program "pillars": internal controls; independent testing; designated BSA officer; training; risk-based CDD incl. beneficial ownership (5th pillar, eff. May 2018) | HIGH |
| **31 CFR 1020.320 (SAR)** | Bank SAR threshold = **$5,000** where illicit activity is known/suspected. **Filing deadline: 30 calendar days** from initial detection; **60 days** if no suspect identified at detection. | HIGH |
| **FinCEN SAR Narrative Guidance** | Narrative must cover **who / what / when / where / why + how (method)**; list **individual dates & amounts**, not just aggregates | HIGH |
| **31 CFR 1010.311 (CTR)** | Mechanical **$10,000** cash threshold; objective, no confidentiality, aggregated per business day. Distinct from SAR. | HIGH |
| **Continuing-activity SAR** | Review every **90 days**; file within **120 days** of the prior related SAR (FinCEN guidance, not strict mandate) | HIGH |
| **Confidentiality / no-tip-off** | SAR existence is confidential; decline subpoenas citing 31 U.S.C. 5318(g)(2)(A)(i); notify FinCEN | HIGH |
| **Record retention** | SAR + supporting docs kept **5 years** from filing | HIGH |
| **SR 11-7 → SR 21-8 → SR 26-2** | Model Risk Management. **SR 26-2 (Apr 17, 2026)** superseded SR 11-7; moves to risk-based oversight **and explicitly places GenAI/agentic AI OUTSIDE its scope** (govern under other practices; RFI coming). Most relevant to banks >$30B. | HIGH |

> **Correction to your brief:** the "$25,000 regardless of suspect" tier does **not** apply to banks — that belongs to other FI types (e.g., securities/futures). Banks file at a flat **$5,000** under 1020.320. *Source: https://www.ecfr.gov/current/title-31/subtitle-B/chapter-X/part-1020/subpart-C/section-1020.320*
>
> **Also flag:** In **March 2025** FinCEN removed BOI (beneficial-ownership) reporting for US domestic companies — only foreign-registered entities now report. Any CTA/BOI logic must reflect this. *Source: https://www.fincen.gov/boi*

### 2.2 EU / Netherlands

| Anchor | What it pins down | Confidence |
|---|---|---|
| **Regulation (EU) 2024/1624 (AMLR)** — *directly applicable, applies from **10 July 2027*** | Art. 19 CDD triggers (business relationship; occasional ≥**€10,000**; cash ≥**€3,000**; suspicion; doubts) incl. linked-transaction aggregation • Art. 20 the four CDD limbs • Art. 22 identify/verify via reliable independent sources • Art. 25 purpose & nature (incl. source of funds) • Art. 26 ongoing monitoring • Arts. 33–46 SDD/EDD/PEPs (PEP ⇒ mandatory EDD + senior-mgmt approval; former PEP in scope ≥12 months) | HIGH |
| **Directive (EU) 2024/1640 (AMLD6)** — transpose by **10 July 2027** | Supervisory architecture, FIUs, BO registers; 25% UBO threshold; staggered dates (BO legitimate-interest access 2025; BARIS 2029) | HIGH |
| **AMLA (Reg. 2024/1620)** | EU AML supervisor, **seat: Frankfurt**; first selection of ~**40** high-risk cross-border institutions in **2027**; **direct supervision begins 2028**. Took over AML mandates from EBA end-2025. | HIGH |
| **Dutch Wwft** | Arts. 3–11 CDD (identify client + UBO, purpose, ongoing monitoring) • EDD for higher risk • **Arts. 16–17 report _unusual_ transactions to FIU-Nederland** • record-keeping **5 years** | HIGH (substance); MEDIUM on exact article numbers (Wwft has been renumbered) |
| **Sanctiewet 1977 + RTSw** | Sanctions screening & asset-freeze; report any "hit" to supervisor (DNB/AFM) without delay | HIGH |

> **The single most important EU-specific nuance — the Dutch "unusual" vs "suspicious" split:** Dutch institutions report **_unusual_ transactions** (*ongebruikelijke transacties*) — a deliberately lower bar set by objective + subjective indicators — to **FIU-Nederland**, which then upgrades a subset to **_suspicious_ (verdacht)** and passes those to law enforcement. This is structurally different from the US "suspicious" standard and changes the investigation decision logic for a Dutch product. *Sources: https://business.gov.nl/regulations/reporting-unusual-transactions/ ; https://lawandmore.eu/money-laundering-vs-unusual-transactions-legal-differences-under-dutch-law/ (HIGH).*

### 2.3 Predecessor EU directives (still the transposed baseline until 2027)
- **2015/849 (4AMLD)** — risk-based foundation; BO register concept; old €15,000 trigger (now €10,000).
- **2018/843 (5AMLD)** — extended to virtual-currency exchanges & custodian wallets; public BO registers.
- **2018/1673** — criminalises ML: ≥4-year max imprisonment; 22 predicate-offence categories; self-laundering. *(All HIGH.)*

---

## 3. Why this is a market: the pain quantified

- **Legacy rules-based transaction monitoring produces ~90–95% false positives** — the most-cited number across the industry and the root driver of investigator toil. *(MEDIUM-HIGH, multi-source.)*
- **Investigator toil:** L2 case work runs ~2–8 hours/case; teams sit permanently behind the alert queue. *(MEDIUM.)*
- **Settlements prove the cost of getting it wrong:** ING **€775m** (2018; €100m of it was disgorgement of money *saved by under-resourcing compliance*); ABN AMRO **€480m** (2021). These drove Dutch banks to thousands of analysts and de-risking. *(HIGH.)*

---

## 4. THE INVESTIGATION FLOW (core deliverable)

A detailed, step-by-step blueprint. Each step lists **(a)** what happens, **(b)** the SOP/regulatory anchor it must ground to, and **(c)** the agentic opportunity. This is the flow your product should encode.

### Stage 0 — Trigger / Alert intake
- **(a)** Alert arrives from transaction-monitoring (rules/scenarios on structuring, rapid movement, sub-threshold patterns, profile-inconsistent behavior) or ML risk score (commonly 1–100), or from employee referral, law-enforcement inquiry, or sanctions hit.
- **(b)** FFIEC Appendix S component 1; AMLR Art. 26 / Wwft ongoing-monitoring; Sanctiewet for screening hits.
- **(c)** Agent ingests the alert + the **triggering rule/score rationale** and pins it as evidence-item #1 with a citation to the rule definition.

### Stage 1 — L1 triage / disposition (target ~5–10 min/alert)
- **(a)** First-line review: clear (with documented rationale) or escalate. Auto-close of low-risk-within-appetite alerts.
- **(b)** FFIEC component 2 ("managing alerts"); **every disposition — including clears — must be documented with rationale** (common exam-finding area).
- **(c)** **Highest-ROI agentic step.** Agent assembles a triage pack (KYC snapshot, recent activity, prior alerts), proposes a disposition with a grounded rationale, and either auto-closes within strict guardrails or routes up. ComplyAdvantage/Hawk/Sardine all target this; the differentiator is **defensible, cited auto-close**.

### Stage 2 — Case investigation (L2/L3, ~2–8 hrs)
- **(a)** Gather and correlate: full transaction history; KYC/customer profile; counterparty & linked-account analysis; adverse media / OSINT; sanctions & PEP screening; prior alerts/SARs. Form a **hypothesis** mapped to a typology.
- **(b)** AMLR Arts. 20/25/26; Wwft Arts. 3–11; FFIEC components 2→3.
- **Typologies to encode as hypothesis templates:** structuring/smurfing • layering (shells, nominees, offshore) • integration (luxury assets) • trade-based ML (over/under-invoicing) • money-mule networks (micro-transactions across many accounts/synthetic IDs). *(HIGH — textbook, multi-source; red-flag list = FFIEC Appendix F.)*
- **(c)** Conversational agent: investigator asks "show me the counterparty network for account X" / "is this consistent with the KYC profile?"; agent retrieves, correlates, visualizes money flow, and proposes the matching typology **with every fact cited to a source record**. This is the **"Investigation Cue"** from your deck, hardened (e.g., *"$50k credited [date]; 73 sub-$1k transactions over 4 days → $49k to Counterparty A → structuring pattern"*).

### Stage 3 — Enhanced Due Diligence (when risk is elevated)
- **(a)** Identity + beneficial-ownership re-verification; PEP/sanctions; **source of funds** (this transaction) vs **source of wealth** (total assets); business-activity profiling; corporate-structure analysis; adverse-media; ongoing-monitoring plan.
- **(b)** AMLR Art. 34 + Arts. 42–46 (PEP: mandatory EDD + senior-mgmt approval); Wwft EDD; US CDD rule.
- **(c)** Agent runs the EDD checklist as a guided, conversational workflow; flags gaps; drafts the SoF/SoW assessment grounded in retrieved evidence.

### Stage 4 — Decision: file or close
- **(a)** Reasoned, documented, timely file/no-file decision. **No-file decisions must also be documented.**
- **(b)** FFIEC component 3; **US: SAR.** **NL: report _unusual_ transaction to FIU-NL** (lower bar — the agent's decision threshold differs by jurisdiction).
- **(c)** **Human-in-the-loop is mandatory here** (four-eyes / maker-checker; AI Act Art. 14; FATF). Agent recommends + assembles the evidence dossier; the **MLRO/BSA Officer decides**. Never auto-file.

### Stage 5 — Narrative drafting & filing
- **(a)** Write the SAR/STR narrative: **who / what / when / where / why / how**, with **individual dates & amounts**. File via FinCEN BSA E-Filing (US) or to FIU-NL (NL).
- **(b)** FinCEN SAR Narrative Guidance; FFIEC Appendix L ("the care with which the narrative is written may make the difference…").
- **(c)** **The single most-proven GenAI use case** (Lucinity, Hawk, Unit21 all do it). Agent drafts an editable narrative **grounded strictly in cited case evidence** — every asserted fact resolves to a source record or is suppressed. Human edits & approves.

### Stage 6 — Continuing activity & record-keeping
- **(a)** Monitor for continuing activity; file continuing SAR (US: review 90d / file within 120d). Retain SAR + supporting docs **5 years**.
- **(b)** FFIEC component 5; 31 CFR 1020.320; Wwft Arts. 33–34.
- **(c)** Agent maintains the case timeline, auto-schedules the 90-day review, and preserves the full immutable audit trail.

### Roles & decision authority (encode as agent permissions)
- **L1** — triage/clear/escalate.
- **L2** — full investigation, drafts SAR/STR.
- **L3 / team lead / QA** — supervises, quality-checks, ensures policy consistency.
- **MLRO (EU/UK) / BSA Officer (US)** — **final file/no-file authority**; owns framework; regulator liaison. *(Designated officer is a hard requirement — 31 CFR 1020.210.)*
- **Binding SLAs** are only the **30/60-day SAR clock** and **5-year retention**; per-stage timeboxes (5–10 min, 2–8 hrs) are industry convention, not regulation.

---

## 5. Tooling & vendor landscape (where the white space is)

**Incumbents (rules + case management):** NICE Actimize (~16% mindshare, declining), SAS AML, Oracle FCCM, **Quantexa** (entity resolution + graph; launched **Q Assist** GenAI copilot at QuanCon25).

**AI-native / GenAI players:**
- **Lucinity** ("Luci" copilot — editable SAR narratives, case summarization, money-flow viz; *claims* 2.5h→30min) — closest to your concept.
- **Hawk:AI** (*claims* 70%+ alert-noise reduction; pushing agentic investigation).
- **ComplyAdvantage** (launched **Mesh**, Oct 2025; *claims* up to **85% of routine alerts auto-resolved** with "regulatory defensibility").
- **Sardine, Unit21, Greenlite AI** (deployed at Grasshopper Bank, First Internet Bank), **Norm Ai** (regulation-as-executable-agents).

**The flagship deployed system — Google Cloud AML AI + HSBC (DRA):** ML risk score replacing rules; **identifies 2–4× more suspicious activity** (≈2× commercial, ≈4× retail) while **reducing alerts ~60%**; HSBC screens **>1.2B transactions/month**. *Built on Vertex AI + BigQuery. (HIGH — verified directly against the Google Cloud blog; but read the 2–4× as a Google/HSBC-reported framing, not an independent audit.)* *Source: https://cloud.google.com/blog/topics/financial-services/how-hsbc-fights-money-launderers-with-artificial-intelligence*

> **White-space conclusion:** Detection/risk-scoring is consolidating (Google, Quantexa, incumbents). Vendors *market* agentic triage and SAR-drafting, but almost all efficiency numbers are **unaudited vendor claims**. A product that wins on **grounded, cited, regulator-defensible conversational investigation** — not just "auto-close %" — is differentiated. Trust/groundedness is the wedge, exactly as your deck argues.

---

## 6. Building it trustworthy & grounded (the hard part)

1. **Governance posture (US):** SR 26-2 (2026) **explicitly excludes GenAI/agentic AI from MRM scope** — so you can't just cite a letter; you must *construct* a defensible governance story and watch for the forthcoming agencies' RFI. *Source: https://www.federalreserve.gov/supervisionreg/srletters/SR2602.htm*
2. **Design to the EU AI Act high-risk stack regardless of the fraud carve-out.** Recital 58 exempts *fraud detection* from high-risk, but the carve-out is **narrow and legally contested** — it does not cleanly cover all AML. Build to **Arts. 9 (lifecycle risk mgmt), 12 (automatic logging), 13 (transparency), 14 (human oversight/override), 15 (accuracy/robustness)** because they double as the trustworthiness checklist. *Source: https://artificialintelligenceact.eu/recital/58/*
3. **XAI as cues, not ground truth.** SHAP reason codes are the standard, but **unstable on GBDT retraining** ("first-mover bias" → same prediction, different top reasons — the exact "retraining instability eroding trust" risk in your deck). Mitigate with **consensus / seed-averaged SHAP**; never present attributions as exact reasoning or as fact.
4. **Architectural groundedness, not model-accuracy groundedness.** "100% grounded" is achievable only as an *architecture*: **every asserted fact must resolve to a cited source record, else it is suppressed/flagged.** Layer: RAG strictly over case evidence + SOPs → sentence-level citation → automated grounding verification → refuse-on-uncertainty. **"Hallucinated citations" are the top risk** — reviewers lower their guard when they see a source. RAG cuts hallucination (one FS deployment: 19% → <1%) but never to zero.
5. **Unbroken, bidirectional audit trail** alert → evidence → rationale → decision → SAR, with **four-eyes/maker-checker** and a **mandatory human SAR-filing decision** (FATF 2021 + AI Act Art. 14 both insist the human stays accountable).
6. **Regulatory tailwind:** the **2018 US Interagency Joint Statement** encourages responsible AML innovation and says good-faith pilots won't draw supervisory criticism; **FATF (2021)** endorses ML while insisting on human oversight and data protection. Lean on both.
7. **Solve the "Data Visa" first.** Data residency (GDPR), PII handling, and a **per-version model-approval gate** are gating preconditions. An **in-jurisdiction / private-deployment architecture with frozen, validated model versions** is effectively required for bank adoption — this directly addresses the HSBC "Data Visa" blocker in your deck.

---

## 7. Recommended product blueprint (synthesis)

> An **agentic, conversational investigation copilot** that sits in the **Remediation/Investigation** white space, grounded end-to-end:

1. **Grounding corpus = the §2 regulatory anchors + the bank's own SOPs/policies**, indexed for RAG with strict citation.
2. **Per-stage agents mapped to §4** (triage → investigate → EDD → recommend → draft), each with **role-scoped permissions** mirroring L1/L2/L3/MLRO authority.
3. **Every output cited** to either a source *record* (transaction, KYC field, screening hit) or a *policy* clause; uncited assertions are suppressed. This operationalizes "100% groundedness."
4. **XAI investigation cues** (stabilized SHAP) translate risk scores into human-readable narratives — your "Investigation Cue," hardened.
5. **Human-in-the-loop gates** at the file/no-file decision and before any SAR filing — never autonomous filing.
6. **Immutable, bidirectional audit trail** + AI Act Art. 12-style logging baked in from day one.
7. **Jurisdiction-aware decision logic:** US "suspicious"/SAR vs Dutch "unusual"/FIU-NL; AMLR thresholds (€10k/€3k) vs US ($5k SAR/$10k CTR).
8. **Deploy in-jurisdiction with frozen, validated model versions** to clear the Data Visa / model-approval gate.

---

## 8. Confidence & caveats

- **HIGH:** US SAR/CTR thresholds & deadlines, FFIEC 5-component spine, 5 W's+how narrative, AMLR/AMLD6/AMLA dates & seat, Dutch unusual-vs-suspicious split, ING/ABN settlements, Google AML AI metrics (verified), SR 26-2 existence + GenAI/agentic exclusion (verified), EU AI Act Recital 58 (verbatim), predecessor directives.
- **MEDIUM:** exact Wwft article numbering (renumbered across amendments — verify on wetten.overheid.nl); SHAP-stability mitigation names; specific RAG hallucination percentages (single-source); FATF 2021 exact wording.
- **LOW (treat as marketing):** all vendor efficiency claims — Lucinity 2.5h→30min, Hawk 70%, ComplyAdvantage 85% auto-resolution, and the precise interpretation of Google's "2–4×" as a true-positive uplift.
- **Corrected from the original brief:** banks file SARs at a flat **$5,000** (not "$25,000 regardless"); the FFIEC/Wwft are the operational SOP, but **legally binding SLAs are only the 30/60-day SAR clock + 5-year retention**.
- **Method caveat:** automated full-page fetching was widely blocked (HTTP 403) across regulator sites; most regulatory facts were corroborated across multiple search extractions and the load-bearing contested claims (SR 26-2, $25k threshold, Google metrics) were independently re-verified. For compliance-grade citation, confirm exact statutory wording on EUR-Lex, eCFR, and wetten.overheid.nl.

### Primary sources to anchor your RAG corpus
- EU AMLR 2024/1624 — https://eur-lex.europa.eu/eli/reg/2024/1624/oj/eng
- EU AMLD6 2024/1640 — https://eur-lex.europa.eu/eli/dir/2024/1640/oj/eng
- Dutch Wwft (DNB) — https://www.dnb.nl/en/sector-information/open-book-supervision/laws-and-eu-regulations/anti-money-laundering-and-anti-terrorist-financing-act/introduction-wwft/
- US SAR rule 31 CFR 1020.320 — https://www.ecfr.gov/current/title-31/subtitle-B/chapter-X/part-1020/subpart-C/section-1020.320
- FinCEN SAR Narrative Guidance — https://www.fincen.gov/system/files/shared/sarnarrcompletguidfinal_112003.pdf
- FFIEC BSA/AML Manual, Appendix S — https://bsaaml.ffiec.gov/manual/Appendices/20
- SR 26-2 (MRM) — https://www.federalreserve.gov/supervisionreg/srletters/SR2602.htm
- 2018 Interagency Innovation Joint Statement — https://www.federalreserve.gov/supervisionreg/srletters/sr1810.htm
- FATF New Technologies for AML/CFT (2021) — https://www.fatf-gafi.org/en/publications/Digitaltransformation/Opportunities-challenges-new-technologies-for-aml-cft.html
- EU AI Act Recital 58 / Arts. 9–15 — https://artificialintelligenceact.eu/recital/58/
- Google Cloud AML AI / HSBC — https://cloud.google.com/blog/topics/financial-services/how-hsbc-fights-money-launderers-with-artificial-intelligence
