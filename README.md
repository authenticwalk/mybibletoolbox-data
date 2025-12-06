# myBibleToolbox Data

**The world's largest AI-readable commentary on the Bible.**

This repository contains structured data designed specifically for AI systems to ground their responses in Biblical truth. Whether you're building a Bible study app, a translation assistant, or integrating Scripture into your AI workflow, this data helps prevent hallucination and ensures accuracy.

## The Problem

AI models are *confident* but not always *accurate* with Biblical texts:
- They perform well on popular passages (John 3:16, Psalm 23) in common translations
- Accuracy degrades on lesser-quoted texts (minor prophets, Numbers, genealogies)
- Rare language translations often get hallucinated entirely
- Theological nuance is frequently lost or distorted

## The Solution

We provide "a book's worth of context" for every verse:
- Source language analysis (Greek/Hebrew with Strong's numbers)
- Cross-references and parallel passages
- Historical and cultural context
- Theological commentary from multiple Christian traditions
- Translation notes and semantic information

All structured as machine-readable YAML files that AI systems can efficiently process.

## What's Inside

| Directory | Description | Size |
|-----------|-------------|------|
| `commentary/` | Verse-by-verse analysis organized by book | ~3 GB |
| `strongs/` | Greek (G0001-G5624) and Hebrew (H0001-H8674) lexicon entries | ~80 MB |
| `databases/` | Pre-built SQLite databases for fast lookups | ~10 MB |

### Databases

Quick-access databases ready for integration:

- **`verse-strongs.sqlite`** - Maps verses to Strong's numbers
  ```sql
  SELECT strongs FROM verse_strongs WHERE reference = 'JHN-001-001'
  -- Returns: G1722,G0746,G1510,G3588,G3056,...
  ```

### Commentary Structure

```
commentary/{BOOK}/{chapter:03d}/{verse:03d}/{BOOK}-{chapter:03d}-{verse:03d}-{tool}.yaml
```

Example: `commentary/JHN/001/001/JHN-001-001-macula.yaml` contains Greek source text analysis for John 1:1.

### Strong's Structure

```
strongs/{G|H}{number:04d}/{G|H}{number:04d}-{tool}.strongs.yaml
```

Example: `strongs/G0026/G0026-strongs.yaml` contains data for *agape* (love).

## Quick Start

### Option 1: Sparse Checkout (Recommended)

Clone only what you need - databases included by default:

```bash
git clone --filter=blob:none --sparse https://github.com/authenticwalk/mybibletoolbox-data.git .data
cd .data                       # !IMPORTANT: you need to be in that directory
./setup-sparse.sh              # Includes databases by default
./setup-sparse.sh JHN ROM      # Also add John and Romans
```

**Add more content later:**
```bash
git sparse-checkout add commentary/GEN    # Add Genesis
git sparse-checkout add strongs           # Add all Strong's entries (~80 MB)
git sparse-checkout list                  # See what's included
```

**To get only certain types:**

```bash
# Enable non-cone mode for pattern matching
git sparse-checkout init --no-cone

# Set pattern to match only macula files
git sparse-checkout set '/.data/commentary/**/*-macula.yaml'

```

### Option 2: Clone Everything (~3 GB)

```bash
git clone https://github.com/authenticwalk/mybibletoolbox-data.git
```

### Understanding Sparse Checkout

Sparse checkout lets you download only the data you need. The full repository is very large, but you might only need:
- `databases/` (~10 MB) - SQLite databases for lookups
- `commentary/JHN/` (~50 MB) - Just the Gospel of John
- `strongs/` (~80 MB) - All Greek/Hebrew lexicon entries

**Commands:**
```bash
git sparse-checkout list                  # What you have
git sparse-checkout add commentary/MAT    # Add a book
git sparse-checkout disable               # Get everything
git sparse-checkout init --cone           # Reset to sparse mode
```

## Use Cases

### Bible Translation
Load verse data to provide translators with source language analysis, semantic domains, and cross-references.

### AI Chatbots
Ground LLM responses in verified Biblical data instead of training memory.

### Study Apps
Build search, cross-reference, and word study features using structured data.

### Research
Access linguistic and theological data in machine-readable format.

## Reference Formats

| Type | Format | Example |
|------|--------|---------|
| Verse | `{BOOK}-{chapter:03d}-{verse:03d}` | `JHN-001-001`, `GEN-001-001`, `1JN-005-021` |
| Strong's | `{G\|H}{number:04d}` | `G0026`, `H0430` |
| Book codes | USFM 3.0 | `GEN`, `EXO`, `MAT`, `JHN`, `1CO`, `REV` |

## Theological Foundation

This is a **Christian** project grounded in conservative Protestant orthodoxy:
- Scripture as God's inerrant Word
- Historic Christian creeds (Nicene, Apostles', Athanasian)
- Core doctrines: Trinity, deity of Christ, salvation by grace through faith

We include perspectives from all Christian traditions (Protestant, Catholic, Orthodox) while clearly distinguishing orthodox Christianity from heterodox views.

## Contributing

**Want to help build the largest AI-readable Bible commentary?**

This repository contains only the data. To contribute:

1. Visit the code repository: **[mybibletoolbox-code](https://github.com/authenticwalk/mybibletoolbox-code)**
2. Read the contribution guidelines
3. Create tools that generate new commentary data
4. Submit pull requests with your generated data

We need help with:
- Source language analysis tools
- Cross-reference mapping
- Historical/cultural context research
- Translation notes
- Quality validation of existing data

## Standards

- **Book codes**: USFM 3.0 (3-letter codes: GEN, MAT, JHN)
- **Language codes**: ISO 639-3 (3-letter codes: eng, heb, grc)
- **Data format**: YAML with inline source citations

See [STANDARDIZATION.md](https://github.com/authenticwalk/mybibletoolbox-code/blob/main/STANDARDIZATION.md) in the code repo for complete specifications.

## License

MIT License - Use freely for any purpose. Attribution appreciated.

---

*"Your word is a lamp for my feet, a light on my path."* - Psalm 119:105
