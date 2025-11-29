# Research Layer - n8n Workflow Documentation

## Overview

The Research Layer is the foundation of the Scripting Automation System, responsible for:

- **Scraping** Fandom Wiki data (characters, episodes, lore)
- **Enriching** data with Perplexity AI (fan theories, analysis)
- **Indexing** all data into Pinecone vector database
- **Querying** and retrieving relevant research for script generation

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    RESEARCH LAYER                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Scrapers   │  │  Enrichment  │  │  Vector DB   │     │
│  │              │  │              │  │              │     │
│  │  Fandom Wiki │─▶│  Perplexity  │─▶│   Pinecone   │     │
│  │              │  │      AI      │  │   Indexing   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                 │                  │             │
│         └─────────────────┴──────────────────┘             │
│                           │                                │
│                  ┌────────▼────────┐                       │
│                  │ Research Agent  │                       │
│                  │ Query & Retrieval│                      │
│                  └─────────────────┘                       │
│                           │                                │
└───────────────────────────┼────────────────────────────────┘
                            │
                     [Research Context]
                            │
                            ▼
                   [Content Builder]
```

## Components

### 1. Fandom Wiki Scraper
**File:** `n8n-workflows/research-layer/scrapers/fandom-wiki-scraper.json`

**Purpose:** Scrapes Fandom Wiki pages to extract:
- Character information (bios, relationships, arcs)
- Episode data (summaries, transcripts, air dates)
- Show lore and world-building details

**Webhook Endpoint:** `/scrape-fandom-wiki`

**Input Parameters:**
```json
{
  "wiki_url": "https://example.fandom.com",
  "show_name": "Show Name",
  "scrape_type": "full" // Options: "full", "characters", "episodes"
}
```

**Output:**
```json
{
  "success": true,
  "items_scraped": 25,
  "data": {
    "character_name": "Character Name",
    "character_bio": "...",
    "relationships": "...",
    "episode_title": "...",
    "episode_summary": "...",
    "transcript": "...",
    "scraped_at": "2025-11-29T00:00:00Z"
  }
}
```

### 2. Perplexity AI Enrichment
**File:** `n8n-workflows/research-layer/enrichment/perplexity-enrichment.json`

**Purpose:** Enriches scraped data with:
- Fan theories and interpretations
- Critical analysis and reviews
- Behind-the-scenes information
- Character/episode deep dives

**Webhook Endpoint:** `/enrich-with-perplexity`

**Input Parameters:**
```json
{
  "topic": "Character Name or Episode Title",
  "show_name": "Show Name",
  "enrichment_type": "comprehensive", // Options: "comprehensive", "fan_theories", "character_analysis", "episode_analysis"
  "context_data": {} // Optional: Previously scraped data
}
```

**Output:**
```json
{
  "success": true,
  "enrichment_complete": true,
  "data": {
    "topic": "Character Name",
    "show_name": "Show Name",
    "comprehensive_analysis": "...",
    "queries_processed": 4,
    "all_citations": ["url1", "url2"],
    "enriched_at": "2025-11-29T00:00:00Z"
  }
}
```

### 3. Pinecone Vector Database Indexer
**File:** `n8n-workflows/research-layer/vector-db/pinecone-indexer.json`

**Purpose:** Indexes all research data into Pinecone for semantic search

**Webhook Endpoint:** `/index-to-pinecone`

**Input Parameters:**
```json
{
  "data": {}, // Data object to index
  "data_type": "fandom_wiki", // Options: "fandom_wiki", "perplexity_enrichment"
  "show_name": "Show Name",
  "namespace": "research-data" // Optional: Defaults to "research-data"
}
```

**Output:**
```json
{
  "success": true,
  "vectors_indexed": 1,
  "namespace": "research-data",
  "show_name": "Show Name",
  "vector_ids": ["char_show_character"],
  "indexed_at": "2025-11-29T00:00:00Z"
}
```

### 4. Research Agent
**File:** `n8n-workflows/research-layer/agents/research-agent.json`

**Purpose:** Queries Pinecone database and retrieves relevant research for script generation

**Webhook Endpoint:** `/research-query`

**Input Parameters:**
```json
{
  "video_topic": "Topic of the video script",
  "show_name": "Show Name",
  "query_type": "comprehensive", // Options: "comprehensive", "character_focused", "episode_focused"
  "top_k": 10 // Number of results to return per query
}
```

**Output:**
```json
{
  "success": true,
  "research_data": {
    "video_topic": "...",
    "show_name": "...",
    "total_results": 25,
    "character_data": {
      "count": 10,
      "top_matches": [...]
    },
    "episode_data": {
      "count": 8,
      "top_matches": [...]
    },
    "enriched_analysis": {
      "count": 7,
      "analyses": [...]
    },
    "full_context": [...] // All results with metadata
  }
}
```

### 5. Research Layer Orchestrator
**File:** `n8n-workflows/research-layer/research-layer-orchestrator.json`

**Purpose:** Master workflow that orchestrates all Research Layer operations

**Webhook Endpoint:** `/research-layer/orchestrate`

**Input Parameters:**
```json
{
  "operation": "initial_setup", // Options: "initial_setup", "research_query", "enrich_data"
  "show_name": "Show Name",
  "wiki_url": "https://example.fandom.com", // Required for initial_setup
  "video_topic": "Video Topic" // Required for research_query
}
```

**Operations:**

1. **initial_setup**: Scrapes wiki → Enriches data → Indexes to Pinecone
2. **research_query**: Queries Pinecone for relevant research
3. **enrich_data**: Enriches specific topic with Perplexity AI

## Setup Instructions

### Prerequisites

1. **n8n Instance** (self-hosted or cloud)
2. **API Keys:**
   - Perplexity AI API key
   - OpenAI API key (for embeddings)
   - Pinecone API key

### Step 1: Import Workflows

1. Open your n8n instance
2. Navigate to **Workflows** → **Import from File**
3. Import each workflow file from `n8n-workflows/research-layer/`:
   - `scrapers/fandom-wiki-scraper.json`
   - `enrichment/perplexity-enrichment.json`
   - `vector-db/pinecone-indexer.json`
   - `agents/research-agent.json`
   - `research-layer-orchestrator.json`

### Step 2: Configure Credentials

#### Perplexity AI
1. Go to **Credentials** → **New**
2. Type: **Header Auth**
3. Name: `Perplexity API Key`
4. Header Name: `Authorization`
5. Header Value: `Bearer YOUR_PERPLEXITY_API_KEY`

#### OpenAI
1. Go to **Credentials** → **New**
2. Type: **OpenAI API**
3. Name: `OpenAI API Key`
4. API Key: `YOUR_OPENAI_API_KEY`

#### Pinecone
1. Go to **Credentials** → **New**
2. Type: **Header Auth**
3. Name: `Pinecone API Key`
4. Header Name: `Api-Key`
5. Header Value: `YOUR_PINECONE_API_KEY`

### Step 3: Configure Pinecone Index

Create a Pinecone index with the following settings:
- **Index Name:** `research-data`
- **Dimensions:** `1536` (for text-embedding-3-small)
- **Metric:** `cosine`
- **Pod Type:** `p1` or `s1` (starter)

### Step 4: Activate Workflows

1. Open each imported workflow
2. Click **Activate** in the top-right corner
3. Note the webhook URLs for each workflow

### Step 5: Set Environment Variables

In your n8n instance, set:
```bash
N8N_WEBHOOK_URL=https://your-n8n-instance.com/webhook
```

## Usage Examples

### Example 1: Initial Setup for a Show

```bash
curl -X POST https://your-n8n-instance.com/webhook/research-layer/orchestrate \
  -H "Content-Type: application/json" \
  -d '{
    "operation": "initial_setup",
    "show_name": "Breaking Bad",
    "wiki_url": "https://breakingbad.fandom.com"
  }'
```

This will:
1. Scrape all character and episode data from the wiki
2. Enrich each character/episode with Perplexity AI analysis
3. Index everything into Pinecone

### Example 2: Query Research for Script Generation

```bash
curl -X POST https://your-n8n-instance.com/webhook/research-layer/orchestrate \
  -H "Content-Type: application/json" \
  -d '{
    "operation": "research_query",
    "show_name": "Breaking Bad",
    "video_topic": "Walter White's transformation in Season 1"
  }'
```

This returns comprehensive research including:
- Character data for Walter White
- Episode summaries from Season 1
- Fan theories and analysis
- All with relevance scores

### Example 3: Enrich Specific Topic

```bash
curl -X POST https://your-n8n-instance.com/webhook/research-layer/orchestrate \
  -H "Content-Type: application/json" \
  -d '{
    "operation": "enrich_data",
    "show_name": "Breaking Bad",
    "video_topic": "The symbolism of color in Breaking Bad"
  }'
```

## Integration with Content Builder

The Research Agent output is designed to feed directly into the Content Builder (Structure Layer):

```javascript
// In your Content Builder workflow
const researchData = $node["Research Agent"].json.research_data;

// Use character data for script context
const characterContext = researchData.character_data.top_matches;

// Use enriched analysis for deeper insights
const analysis = researchData.enriched_analysis.analyses;

// Build script sections with this context
```

## Troubleshooting

### Issue: Scraper returns empty data
- **Cause:** Wiki page structure may have changed
- **Solution:** Update CSS selectors in the scraper workflow

### Issue: Pinecone indexing fails
- **Cause:** Incorrect index dimensions or missing API key
- **Solution:** Verify index configuration and credentials

### Issue: Perplexity API rate limits
- **Cause:** Too many concurrent requests
- **Solution:** Add delay nodes between API calls

## Monitoring & Maintenance

### Recommended Monitoring
1. Track scraping success rates
2. Monitor Pinecone index size
3. Review Perplexity API usage
4. Check embedding quality scores

### Regular Maintenance
1. Update scrapers if wiki structure changes
2. Refresh enriched data periodically (e.g., monthly)
3. Archive old data to manage Pinecone costs
4. Review and update query formulations

## Cost Estimation

Based on typical usage:

- **Perplexity AI:** ~$0.001 per query (4 queries per enrichment)
- **OpenAI Embeddings:** ~$0.0001 per 1K tokens
- **Pinecone:** ~$70/month for p1 pod (free tier available)

**Initial Setup (100 characters + 100 episodes):**
- Perplexity: $0.80 (200 items × 4 queries × $0.001)
- OpenAI: $0.20 (200 items × ~1K tokens × $0.0001)
- **Total:** ~$1.00

**Ongoing (per script):**
- Research Query: $0.01
- Enrichment: $0.004
- **Total per script:** ~$0.014

## Next Steps

After setting up the Research Layer:

1. **Test with sample data** - Run initial_setup for a small show
2. **Verify Pinecone indexing** - Check vector database in Pinecone console
3. **Test research queries** - Query for various topics and review results
4. **Integrate with Structure Layer** - Connect to Hook Writer and Section Writer workflows
5. **Set up monitoring** - Track workflow executions and errors

## Support

For issues or questions:
- Review workflow execution logs in n8n
- Check API credentials and quotas
- Verify Pinecone index configuration
- Consult n8n community forums

---

**Version:** 1.0
**Last Updated:** 2025-11-29
**Maintained by:** Scripting Automation Team
