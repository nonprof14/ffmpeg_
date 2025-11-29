# Research Layer API Reference

Complete API documentation for all Research Layer endpoints.

## Base URL

```
https://your-n8n-instance.com/webhook
```

## Authentication

Currently, the webhooks are unauthenticated. In production, you should:
1. Enable webhook authentication in n8n settings
2. Use API keys or JWT tokens
3. Implement rate limiting

---

## Endpoints

### 1. Scrape Fandom Wiki

Scrapes Fandom Wiki pages for character, episode, and lore data.

**Endpoint:** `POST /scrape-fandom-wiki`

**Request Body:**
```json
{
  "wiki_url": "string (required)",
  "show_name": "string (required)",
  "scrape_type": "string (optional)"
}
```

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| wiki_url | string | Yes | - | Base URL of the Fandom Wiki |
| show_name | string | Yes | - | Name of the show |
| scrape_type | string | No | "full" | Type of scraping: "full", "characters", "episodes" |

**Example Request:**
```bash
curl -X POST https://your-n8n-instance.com/webhook/scrape-fandom-wiki \
  -H "Content-Type: application/json" \
  -d '{
    "wiki_url": "https://breakingbad.fandom.com",
    "show_name": "Breaking Bad",
    "scrape_type": "characters"
  }'
```

**Response:**
```json
{
  "success": true,
  "items_scraped": 25,
  "data": {
    "character_name": "Walter White",
    "character_bio": ["Walter Hartwell White Sr...", "..."],
    "infobox_data": "<div class='portable-infobox'>...</div>",
    "relationships": "Married to Skyler White...",
    "scraped_at": "2025-11-29T10:30:00Z",
    "show_name": "Breaking Bad",
    "data_type": "fandom_wiki"
  }
}
```

**Error Responses:**

| Status Code | Description |
|-------------|-------------|
| 400 | Missing required parameters |
| 500 | Scraping failed (wiki not accessible, invalid URL) |

---

### 2. Enrich with Perplexity AI

Enriches data with Perplexity AI for fan theories, analysis, and contextual information.

**Endpoint:** `POST /enrich-with-perplexity`

**Request Body:**
```json
{
  "topic": "string (required)",
  "show_name": "string (required)",
  "enrichment_type": "string (optional)",
  "context_data": "object (optional)"
}
```

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| topic | string | Yes | - | Character name, episode title, or topic to enrich |
| show_name | string | Yes | - | Name of the show |
| enrichment_type | string | No | "comprehensive" | Type: "comprehensive", "fan_theories", "character_analysis", "episode_analysis" |
| context_data | object | No | {} | Previously scraped data for additional context |

**Example Request:**
```bash
curl -X POST https://your-n8n-instance.com/webhook/enrich-with-perplexity \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "Walter White",
    "show_name": "Breaking Bad",
    "enrichment_type": "character_analysis"
  }'
```

**Response:**
```json
{
  "success": true,
  "enrichment_complete": true,
  "data": {
    "topic": "Walter White",
    "show_name": "Breaking Bad",
    "enrichment_type": "character_analysis",
    "queries_processed": 3,
    "comprehensive_analysis": "### Query 1: Deep character analysis...\n\n### Query 2: Walter White character arc...",
    "all_citations": [
      "https://example.com/article1",
      "https://example.com/article2"
    ],
    "enriched_at": "2025-11-29T10:35:00Z",
    "data_type": "perplexity_enrichment"
  }
}
```

**Enrichment Types:**

| Type | Description | Queries Generated |
|------|-------------|-------------------|
| comprehensive | Full analysis including theories, character arcs, and impact | 4 queries |
| fan_theories | Focus on fan theories and hidden meanings | 3 queries |
| character_analysis | Deep dive into character development | 3 queries |
| episode_analysis | Episode themes, symbolism, and production details | 3 queries |

**Error Responses:**

| Status Code | Description |
|-------------|-------------|
| 400 | Missing required parameters |
| 429 | Perplexity API rate limit exceeded |
| 500 | Enrichment failed |

---

### 3. Index to Pinecone

Indexes scraped and enriched data into Pinecone vector database.

**Endpoint:** `POST /index-to-pinecone`

**Request Body:**
```json
{
  "data": "object (required)",
  "data_type": "string (required)",
  "show_name": "string (required)",
  "namespace": "string (optional)"
}
```

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| data | object | Yes | - | Data object to index (from scraper or enrichment) |
| data_type | string | Yes | - | Type: "fandom_wiki" or "perplexity_enrichment" |
| show_name | string | Yes | - | Name of the show |
| namespace | string | No | "research-data" | Pinecone namespace |

**Example Request:**
```bash
curl -X POST https://your-n8n-instance.com/webhook/index-to-pinecone \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "character_name": "Walter White",
      "character_bio": "...",
      "relationships": "..."
    },
    "data_type": "fandom_wiki",
    "show_name": "Breaking Bad",
    "namespace": "research-data"
  }'
```

**Response:**
```json
{
  "success": true,
  "vectors_indexed": 1,
  "namespace": "research-data",
  "show_name": "Breaking Bad",
  "data_type": "fandom_wiki",
  "indexed_at": "2025-11-29T10:40:00Z",
  "vector_ids": ["char_breaking_bad_walter_white"]
}
```

**Vector ID Format:**

| Data Type | Format |
|-----------|--------|
| Character | `char_{show_name}_{character_name}` |
| Episode | `ep_{show_name}_{episode_number}` |
| Enrichment | `enriched_{show_name}_{topic}` |

**Error Responses:**

| Status Code | Description |
|-------------|-------------|
| 400 | Invalid data format or missing parameters |
| 500 | Pinecone indexing failed, OpenAI embedding error |

---

### 4. Research Query

Queries the Pinecone database to retrieve relevant research for script generation.

**Endpoint:** `POST /research-query`

**Request Body:**
```json
{
  "video_topic": "string (required)",
  "show_name": "string (required)",
  "query_type": "string (optional)",
  "top_k": "number (optional)"
}
```

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| video_topic | string | Yes | - | Topic of the video script |
| show_name | string | Yes | - | Name of the show |
| query_type | string | No | "comprehensive" | Type: "comprehensive", "character_focused", "episode_focused" |
| top_k | number | No | 10 | Number of results per query |

**Example Request:**
```bash
curl -X POST https://your-n8n-instance.com/webhook/research-query \
  -H "Content-Type: application/json" \
  -d '{
    "video_topic": "Walter White transformation in Season 1",
    "show_name": "Breaking Bad",
    "query_type": "comprehensive",
    "top_k": 10
  }'
```

**Response:**
```json
{
  "success": true,
  "research_data": {
    "video_topic": "Walter White transformation in Season 1",
    "show_name": "Breaking Bad",
    "research_completed_at": "2025-11-29T10:45:00Z",
    "total_results": 25,
    "character_data": {
      "count": 10,
      "top_matches": [
        {
          "name": "Walter White",
          "relevance_score": 0.95,
          "source": "fandom_wiki"
        },
        {
          "name": "Jesse Pinkman",
          "relevance_score": 0.87,
          "source": "fandom_wiki"
        }
      ]
    },
    "episode_data": {
      "count": 8,
      "top_matches": [
        {
          "title": "Pilot",
          "episode_number": "S01E01",
          "relevance_score": 0.92,
          "source": "fandom_wiki"
        }
      ]
    },
    "enriched_analysis": {
      "count": 7,
      "analyses": [
        {
          "topic": "Walter White character arc",
          "enrichment_type": "character_analysis",
          "relevance_score": 0.94,
          "citations": ["https://example.com/analysis1"]
        }
      ]
    },
    "full_context": [
      {
        "id": "char_breaking_bad_walter_white",
        "score": 0.95,
        "metadata": {
          "type": "character",
          "show_name": "Breaking Bad",
          "character_name": "Walter White",
          "source": "fandom_wiki"
        }
      }
    ]
  }
}
```

**Query Types:**

| Type | Description | Queries Generated |
|------|-------------|-------------------|
| comprehensive | Broad search across characters, episodes, and analysis | 5 queries |
| character_focused | Focus on character data and relationships | 3 queries |
| episode_focused | Focus on episode summaries and plots | 3 queries |

**Error Responses:**

| Status Code | Description |
|-------------|-------------|
| 400 | Missing required parameters |
| 404 | No results found for query |
| 500 | Pinecone query failed, OpenAI embedding error |

---

### 5. Research Layer Orchestrator

Master endpoint that coordinates all Research Layer operations.

**Endpoint:** `POST /research-layer/orchestrate`

**Request Body:**
```json
{
  "operation": "string (required)",
  "show_name": "string (required)",
  "wiki_url": "string (conditional)",
  "video_topic": "string (conditional)"
}
```

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| operation | string | Yes | - | Operation: "initial_setup", "research_query", "enrich_data" |
| show_name | string | Yes | - | Name of the show |
| wiki_url | string | Conditional | - | Required for "initial_setup" |
| video_topic | string | Conditional | - | Required for "research_query" and "enrich_data" |

---

#### Operation: initial_setup

Performs complete initial setup: scrape → enrich → index.

**Example Request:**
```bash
curl -X POST https://your-n8n-instance.com/webhook/research-layer/orchestrate \
  -H "Content-Type: application/json" \
  -d '{
    "operation": "initial_setup",
    "show_name": "Breaking Bad",
    "wiki_url": "https://breakingbad.fandom.com"
  }'
```

**Response:**
```json
{
  "operation": "initial_setup",
  "show_name": "Breaking Bad",
  "scraping_complete": true,
  "enrichment_complete": true,
  "indexing_complete": true,
  "total_items_processed": 150,
  "vectors_indexed": 150,
  "completed_at": "2025-11-29T11:00:00Z"
}
```

---

#### Operation: research_query

Queries research database for script context.

**Example Request:**
```bash
curl -X POST https://your-n8n-instance.com/webhook/research-layer/orchestrate \
  -H "Content-Type: application/json" \
  -d '{
    "operation": "research_query",
    "show_name": "Breaking Bad",
    "video_topic": "Walter White transformation"
  }'
```

**Response:**
```json
{
  "operation": "research_query",
  "success": true,
  "research_data": {
    "video_topic": "Walter White transformation",
    "show_name": "Breaking Bad",
    "total_results": 25,
    "character_data": {...},
    "episode_data": {...},
    "enriched_analysis": {...},
    "full_context": [...]
  }
}
```

---

#### Operation: enrich_data

Enriches specific topic with Perplexity AI.

**Example Request:**
```bash
curl -X POST https://your-n8n-instance.com/webhook/research-layer/orchestrate \
  -H "Content-Type: application/json" \
  -d '{
    "operation": "enrich_data",
    "show_name": "Breaking Bad",
    "video_topic": "Symbolism of color in Breaking Bad"
  }'
```

**Response:**
```json
{
  "operation": "enrich_data",
  "success": true,
  "enrichment_complete": true,
  "data": {
    "topic": "Symbolism of color in Breaking Bad",
    "comprehensive_analysis": "...",
    "queries_processed": 4,
    "all_citations": [...]
  }
}
```

**Error Responses:**

| Status Code | Description |
|-------------|-------------|
| 400 | Invalid operation or missing required parameters |
| 500 | Operation failed at any step |

---

## Rate Limits

### Recommended Limits

| Endpoint | Requests/min | Requests/hour |
|----------|--------------|---------------|
| scrape-fandom-wiki | 10 | 100 |
| enrich-with-perplexity | 5 | 50 |
| index-to-pinecone | 60 | 1000 |
| research-query | 60 | 1000 |

### API Provider Limits

- **Perplexity AI:** 20 requests/min (varies by plan)
- **OpenAI:** 3000 requests/min (varies by tier)
- **Pinecone:** 100 requests/sec (varies by plan)

---

## Error Handling

### Standard Error Response

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {}
  }
}
```

### Common Error Codes

| Code | Description | Resolution |
|------|-------------|------------|
| MISSING_PARAMETER | Required parameter missing | Check request body |
| INVALID_WIKI_URL | Wiki URL is invalid or unreachable | Verify URL format |
| SCRAPING_FAILED | HTML parsing failed | Check CSS selectors |
| API_RATE_LIMIT | External API rate limit | Retry with backoff |
| EMBEDDING_FAILED | OpenAI embedding generation failed | Check API key |
| INDEXING_FAILED | Pinecone indexing failed | Verify index config |
| NO_RESULTS | Query returned no results | Try different query |

---

## Webhooks & Events

### Webhook Configuration

To receive updates on long-running operations:

1. Set up a webhook endpoint
2. Configure in n8n workflow
3. Receive POST requests with event data

### Event Types

| Event | Trigger | Payload |
|-------|---------|---------|
| scraping.started | Scraping begins | `{ "show_name", "scrape_type", "started_at" }` |
| scraping.completed | Scraping finishes | `{ "show_name", "items_scraped", "completed_at" }` |
| enrichment.started | Enrichment begins | `{ "topic", "enrichment_type", "started_at" }` |
| enrichment.completed | Enrichment finishes | `{ "topic", "queries_processed", "completed_at" }` |
| indexing.completed | Indexing finishes | `{ "vectors_indexed", "namespace", "completed_at" }` |

---

## SDK Examples

### JavaScript/Node.js

```javascript
const axios = require('axios');

const baseURL = 'https://your-n8n-instance.com/webhook';

// Initialize show research
async function initializeShow(showName, wikiUrl) {
  try {
    const response = await axios.post(`${baseURL}/research-layer/orchestrate`, {
      operation: 'initial_setup',
      show_name: showName,
      wiki_url: wikiUrl
    });
    return response.data;
  } catch (error) {
    console.error('Initialization failed:', error.response.data);
    throw error;
  }
}

// Query research for script
async function queryResearch(showName, videoTopic) {
  try {
    const response = await axios.post(`${baseURL}/research-layer/orchestrate`, {
      operation: 'research_query',
      show_name: showName,
      video_topic: videoTopic
    });
    return response.data.research_data;
  } catch (error) {
    console.error('Research query failed:', error.response.data);
    throw error;
  }
}

// Usage
(async () => {
  // Initialize
  await initializeShow('Breaking Bad', 'https://breakingbad.fandom.com');

  // Query
  const research = await queryResearch('Breaking Bad', 'Walter White Season 1');
  console.log('Research results:', research);
})();
```

### Python

```python
import requests

BASE_URL = 'https://your-n8n-instance.com/webhook'

def initialize_show(show_name, wiki_url):
    """Initialize show research database"""
    response = requests.post(
        f'{BASE_URL}/research-layer/orchestrate',
        json={
            'operation': 'initial_setup',
            'show_name': show_name,
            'wiki_url': wiki_url
        }
    )
    response.raise_for_status()
    return response.json()

def query_research(show_name, video_topic):
    """Query research for script generation"""
    response = requests.post(
        f'{BASE_URL}/research-layer/orchestrate',
        json={
            'operation': 'research_query',
            'show_name': show_name,
            'video_topic': video_topic
        }
    )
    response.raise_for_status()
    return response.json()['research_data']

# Usage
if __name__ == '__main__':
    # Initialize
    initialize_show('Breaking Bad', 'https://breakingbad.fandom.com')

    # Query
    research = query_research('Breaking Bad', 'Walter White Season 1')
    print(f"Total results: {research['total_results']}")
```

### cURL

```bash
#!/bin/bash

BASE_URL="https://your-n8n-instance.com/webhook"

# Initialize show
initialize_show() {
  curl -X POST "$BASE_URL/research-layer/orchestrate" \
    -H "Content-Type: application/json" \
    -d "{
      \"operation\": \"initial_setup\",
      \"show_name\": \"$1\",
      \"wiki_url\": \"$2\"
    }"
}

# Query research
query_research() {
  curl -X POST "$BASE_URL/research-layer/orchestrate" \
    -H "Content-Type: application/json" \
    -d "{
      \"operation\": \"research_query\",
      \"show_name\": \"$1\",
      \"video_topic\": \"$2\"
    }"
}

# Usage
initialize_show "Breaking Bad" "https://breakingbad.fandom.com"
query_research "Breaking Bad" "Walter White Season 1"
```

---

## Versioning

API Version: **v1.0**

Version information is not currently included in endpoints. Future versions will use:
```
/v2/research-layer/orchestrate
```

---

## Support

For API issues:
- Check workflow execution logs in n8n
- Verify API credentials are valid
- Review rate limits
- Consult [Setup Guide](RESEARCH_LAYER_SETUP.md)

---

**Last Updated:** 2025-11-29
**Version:** 1.0
