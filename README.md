# 🧬 CPTAC Multi-omics Search Engine & TF-IDF Text Mining

This project builds an advanced multi-omics search engine by integrating R-based text mining (TF-IDF) with a Relational Database (RDB). It transforms biological knowledge into a searchable index and utilizes complex SQL joins to discover breast cancer biomarkers, effectively bridging IT architecture with precision medicine.

## 👤 Identity & Goals
- **Interest**: Computational Biology & Precision Medicine
- **Objective**: To transition from subjective biomarker selection to a **data-driven approach**. By applying mathematical text mining algorithms to biological literature and optimizing an SQL-based architecture, this project aims to create a reliable system for targeted therapy research.

## 🛠 Tech Stack
- **Language**: `R`, `SQL` (Oracle/MySQL compatible)
- **Libraries**: `BiocManager` (`AnnotationDbi`, `org.Hs.eg.db`, `GO.db`), `tidytext`, `dplyr`, `ggplot2`
- **Core Skills**: TF-IDF Algorithm, Zipf's Law Validation, Multi-table SQL JOINs, String Manipulation (`substr`, `instr`), Bioinformatics Database Architecture

## 📂 Project Structure & Workflow

### 1. Biological Domain Knowledge Mapping (R)
* **API Integration**: Utilized Bioconductor packages (`AnnotationDbi`, `GO.db`) to query thousands of Gene Symbols.
* **Feature Extraction**: Successfully extracted the Full Name (GENENAME) and Biological Process (BP) texts for each protein, transforming simple IDs into meaningful biological data.

### 2. TF-IDF Text Mining & Mathematical Validation (R)
* **Noise Reduction**: Applied `tidytext` to remove general biological stop-words (e.g., 'process', 'cell') for precise keyword extraction.
* **Zipf's Law Validation**: Validated the natural language pattern of the biological texts by visualizing word frequency vs. rank on a Log-Log scale.
* **Index Generation**: Calculated TF-IDF scores to extract the **Top 5 most distinct biological keywords** for every protein, creating a dedicated `Search Index` table.

### 3. Database Architecture Optimization (SQL)
* **Bridge Table Design**: Maintained the `Protein_Metadata` table purely for ID mapping (bridging text indexes with expression values), adhering strictly to database normalization principles.
* **Data Import**: Successfully loaded 5 structural tables (Patient, Sample, Expression, Metadata, Search Index) using SQL Loader control files.

### 4. Multi-Omics Biomarker Discovery (SQL)
* **Dynamic Parsing**: Resolved ID format mismatches between tables using SQL string functions (`substr`, `instr`).
* **Complex JOIN Queries**: Executed a simulation query to identify high-expression proteins related to "immune" responses specifically within the 'Basal' (TNBC) subtype cohort.

## 📸 Key Outputs
<img width="2284" height="1413" alt="스크린샷 2026-05-01 111626" src="https://github.com/user-attachments/assets/99f1c060-8541-447a-9b33-23f6592c4efb" />
<img width="2104" height="1489" alt="스크린샷 2026-05-02 002025" src="https://github.com/user-attachments/assets/574af101-72b5-448e-9433-be9e33097277" />
<img width="1966" height="935" alt="스크린샷 2026-05-03 151332" src="https://github.com/user-attachments/assets/79f02d1b-967b-4b2e-8d82-2490033f9da4" />
<img width="1574" height="834" alt="스크린샷 2026-05-02 004211" src="https://github.com/user-attachments/assets/8e919323-4cb6-4015-a043-2f646bfec00e" />

## 💡 Key Experience
- **Bio-IT Synergy**: Demonstrated the power of combining mathematical algorithms (TF-IDF) with biological domain knowledge (Gene Ontology) for objective biomarker discovery.
- **Advanced Database Engineering**: Designed a robust search engine architecture where a text-based search instantly maps to clinical conditions and multi-omics expression values using complex SQL joins.
- **Data-Driven Insight**: Overcame the limitations of manual curation by mathematically proving the importance of Inverse Document Frequency (IDF) in biological text mining.

**Blog**: [밈뮴 블로그 링크](https://blog.naver.com/minng705/224273344516)
