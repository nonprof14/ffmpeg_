# Scripting Automation System - Research Layer

> **n8n workflows for automated script research, enrichment, and retrieval**

This repository contains the **Research Layer** implementation for the Scripting Automation System - a comprehensive solution for gathering, enriching, and retrieving research data for video script generation.

## 🎯 What is the Research Layer?

The Research Layer is the foundation of an AI-powered scripting system that:

- 🔍 **Scrapes** Fandom Wiki pages for character, episode, and lore data
- 🧠 **Enriches** data with Perplexity AI for fan theories and deep analysis
- 📊 **Indexes** everything into Pinecone vector database for semantic search
- 🎬 **Retrieves** relevant research context for script generation

## 📋 System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                 SCRIPTING AUTOMATION SYSTEM                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐  │
│  │  Research     │  │  Structure    │  │   Writing     │  │
│  │  Layer        │─▶│  Layer        │─▶│   Layer       │  │
│  │               │  │               │  │               │  │
│  │ [THIS REPO]   │  │ (Coming Soon) │  │ (Coming Soon) │  │
│  └───────────────┘  └───────────────┘  └───────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Research Layer Components

```
Research Layer
├── Scrapers
│   └── Fandom Wiki Scraper
│       ├── Character data extraction
│       ├── Episode information
│       └── Lore & world-building
│
├── Enrichment
│   └── Perplexity AI Integration
│       ├── Fan theories
│       ├── Critical analysis
│       └── Behind-the-scenes info
│
├── Vector Database
│   └── Pinecone Indexer
│       ├── Embedding generation (OpenAI)
│       ├── Semantic indexing
│       └── Metadata management
│
└── Research Agent
    └── Query & Retrieval
        ├── Semantic search
        ├── Result ranking
        └── Context aggregation
```

## 🚀 Quick Start

### Prerequisites

- n8n instance (self-hosted or cloud)
- API Keys:
  - [Perplexity AI](https://www.perplexity.ai/)
  - [OpenAI](https://platform.openai.com/)
  - [Pinecone](https://www.pinecone.io/)

### Installation

1. **Clone this repository**
   ```bash
   git clone https://github.com/yourusername/scripting-automation-research-layer.git
   cd scripting-automation-research-layer
   ```

2. **Import workflows into n8n**
   - Open your n8n instance
   - Navigate to **Workflows** → **Import from File**
   - Import all `.json` files from `n8n-workflows/research-layer/`

3. **Configure credentials**
   - Set up API credentials in n8n (see [Setup Guide](docs/RESEARCH_LAYER_SETUP.md))
   - Configure Pinecone index

4. **Activate workflows**
   - Activate all imported workflows
   - Note the webhook URLs

### Basic Usage

**Initialize a show's research database:**
```bash
curl -X POST https://your-n8n-instance.com/webhook/research-layer/orchestrate \
  -H "Content-Type: application/json" \
  -d '{
    "operation": "initial_setup",
    "show_name": "Breaking Bad",
    "wiki_url": "https://breakingbad.fandom.com"
  }'
```

**Query research for script generation:**
```bash
curl -X POST https://your-n8n-instance.com/webhook/research-layer/orchestrate \
  -H "Content-Type: application/json" \
  -d '{
    "operation": "research_query",
    "show_name": "Breaking Bad",
    "video_topic": "Walter White's character arc"
  }'
```

## 📂 Repository Structure

```
.
├── n8n-workflows/
│   └── research-layer/
│       ├── scrapers/
│       │   └── fandom-wiki-scraper.json
│       ├── enrichment/
│       │   └── perplexity-enrichment.json
│       ├── vector-db/
│       │   └── pinecone-indexer.json
│       ├── agents/
│       │   └── research-agent.json
│       └── research-layer-orchestrator.json
│
├── docs/
│   ├── RESEARCH_LAYER_SETUP.md
│   └── API_REFERENCE.md
│
├── scripts/
│   └── (Helper scripts for testing and maintenance)
│
└── README.md
```

## 🔧 Workflows Overview

### 1. Fandom Wiki Scraper
**Endpoint:** `/scrape-fandom-wiki`

Scrapes Fandom Wiki pages to extract structured data about characters, episodes, and lore.

**Key Features:**
- Supports selective scraping (characters only, episodes only, or full)
- Extracts character bios, relationships, and arcs
- Captures episode summaries, transcripts, and metadata

### 2. Perplexity AI Enrichment
**Endpoint:** `/enrich-with-perplexity`

Enriches scraped data with deep analysis using Perplexity AI's online search capabilities.

**Key Features:**
- Multiple query types (comprehensive, fan theories, character analysis)
- Citation tracking
- Context-aware enrichment

### 3. Pinecone Vector DB Indexer
**Endpoint:** `/index-to-pinecone`

Indexes all research data into Pinecone for semantic search and retrieval.

**Key Features:**
- Automatic embedding generation (OpenAI)
- Metadata preservation
- Namespace management

### 4. Research Agent
**Endpoint:** `/research-query`

Queries the Pinecone database and retrieves relevant research for script generation.

**Key Features:**
- Semantic search with multiple query formulations
- Result ranking and deduplication
- Organized context aggregation

### 5. Research Layer Orchestrator
**Endpoint:** `/research-layer/orchestrate`

Master workflow that coordinates all Research Layer operations.

**Key Features:**
- Initial setup automation (scrape → enrich → index)
- Research query routing
- Direct enrichment for ad-hoc topics

## 📊 Data Flow

```
┌─────────────┐
│  UI Input   │
│ (Webhook)   │
└──────┬──────┘
       │
       ▼
┌─────────────────────────┐
│  Orchestrator           │
│  - Route operation      │
│  - Coordinate workflows │
└──────┬──────────────────┘
       │
       ├─────────────────┐
       │                 │
       ▼                 ▼
┌─────────────┐   ┌──────────────┐
│  Scraper    │   │  Research    │
│  - Wiki     │   │  Agent       │
│  - Extract  │   │  - Query     │
└──────┬──────┘   │  - Retrieve  │
       │          └──────┬───────┘
       ▼                 │
┌─────────────┐          │
│ Enrichment  │          │
│ - Perplexity│          │
│ - Analysis  │          │
└──────┬──────┘          │
       │                 │
       ▼                 │
┌─────────────┐          │
│  Indexer    │          │
│  - Embed    │◀─────────┘
│  - Store    │  (Query)
└─────────────┘
```

## 🎓 Use Cases

### Content Creators
- **YouTube Scriptwriters:** Generate well-researched scripts about TV shows, anime, movies
- **Video Essayists:** Access deep analysis and fan theories
- **Pop Culture Channels:** Quick access to character arcs and episode summaries

### Production Teams
- **Script Development:** Automated research for episodic content
- **Fact-Checking:** Verify character details and plot points
- **Continuity Management:** Track relationships and story arcs

### Fan Communities
- **Wiki Maintenance:** Automated data extraction and organization
- **Analysis Archives:** Preserve critical analyses and theories
- **Community Knowledge Base:** Searchable repository of show information

## 📈 Performance & Costs

### Typical Performance
- **Initial Setup (100 items):** ~10-15 minutes
- **Research Query:** ~2-3 seconds
- **Single Enrichment:** ~5-10 seconds

### Cost Estimates (per show)
- **Initial Setup:** ~$1.00
- **Per Script Query:** ~$0.01
- **Monthly Pinecone:** $0 (free tier) - $70 (p1 pod)

## 🛠️ Development

### Testing Workflows

```bash
# Test Fandom Wiki Scraper
curl -X POST https://your-n8n-instance.com/webhook/scrape-fandom-wiki \
  -d '{"wiki_url":"https://breakingbad.fandom.com","show_name":"Breaking Bad","scrape_type":"characters"}'

# Test Research Agent
curl -X POST https://your-n8n-instance.com/webhook/research-query \
  -d '{"video_topic":"Walter White","show_name":"Breaking Bad","query_type":"character_focused"}'
```

### Customization

All workflows are fully customizable:
- Modify CSS selectors for different wiki structures
- Adjust Perplexity query templates
- Customize embedding models
- Add additional enrichment sources

## 📚 Documentation

- **[Setup Guide](docs/RESEARCH_LAYER_SETUP.md)** - Complete installation and configuration
- **[API Reference](docs/API_REFERENCE.md)** - Detailed API documentation
- **Workflow Diagrams** - Visual representation of each workflow

## 🤝 Contributing

Contributions welcome! Areas for improvement:
- Additional scraper sources (IMDB, TV Tropes, etc.)
- More enrichment providers
- Performance optimizations
- Error handling improvements
- Additional query strategies

## 📝 Roadmap

### Phase 1: Research Layer ✅ (Current)
- [x] Fandom Wiki scraper
- [x] Perplexity AI enrichment
- [x] Pinecone vector database
- [x] Research Agent

### Phase 2: Structure Layer (Coming Soon)
- [ ] Hook Writer
- [ ] Section Writer
- [ ] Open Loop Agent
- [ ] Examples database integration

### Phase 3: Writing Layer (Future)
- [ ] Content Builder
- [ ] Style Matcher
- [ ] QA Reviewer
- [ ] Feedback Processor

### Phase 4: Continuous Improvement (Future)
- [ ] Human feedback loop
- [ ] Examples database updates
- [ ] Performance analytics
- [ ] A/B testing framework

## ⚖️ License

MIT License - see [LICENSE](LICENSE) file for details

## 🙏 Acknowledgments

- Built with [n8n](https://n8n.io/) - Fair-code workflow automation
- Powered by [Perplexity AI](https://www.perplexity.ai/) for enrichment
- Vector search by [Pinecone](https://www.pinecone.io/)
- Embeddings by [OpenAI](https://openai.com/)

## 💬 Support

- **Documentation:** [docs/](docs/)
- **Issues:** [GitHub Issues](https://github.com/yourusername/repo/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/repo/discussions)

---

**Built for creators, by creators** 🎬

*Part of the Scripting Automation System project*
