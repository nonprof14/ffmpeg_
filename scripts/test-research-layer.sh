#!/bin/bash

# Research Layer Test Script
# Tests all endpoints and validates responses

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
N8N_WEBHOOK_URL="${N8N_WEBHOOK_URL:-https://your-n8n-instance.com/webhook}"
SHOW_NAME="${SHOW_NAME:-Breaking Bad}"
WIKI_URL="${WIKI_URL:-https://breakingbad.fandom.com}"
VIDEO_TOPIC="${VIDEO_TOPIC:-Walter White transformation}"

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
print_header() {
    echo ""
    echo "=========================================="
    echo "$1"
    echo "=========================================="
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
    ((TESTS_PASSED++))
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    ((TESTS_FAILED++))
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Test functions
test_fandom_scraper() {
    print_header "Testing Fandom Wiki Scraper"

    print_info "Scraping characters from $WIKI_URL..."

    response=$(curl -s -X POST "$N8N_WEBHOOK_URL/scrape-fandom-wiki" \
        -H "Content-Type: application/json" \
        -d "{
            \"wiki_url\": \"$WIKI_URL\",
            \"show_name\": \"$SHOW_NAME\",
            \"scrape_type\": \"characters\"
        }")

    # Check if response contains success
    if echo "$response" | grep -q '"success":true'; then
        print_success "Fandom Wiki Scraper works correctly"
        print_info "Response preview:"
        echo "$response" | jq -r '.data | keys | .[:5] | join(", ")'
    else
        print_error "Fandom Wiki Scraper failed"
        echo "$response" | jq '.'
    fi
}

test_perplexity_enrichment() {
    print_header "Testing Perplexity AI Enrichment"

    print_info "Enriching data for: $VIDEO_TOPIC..."

    response=$(curl -s -X POST "$N8N_WEBHOOK_URL/enrich-with-perplexity" \
        -H "Content-Type: application/json" \
        -d "{
            \"topic\": \"$VIDEO_TOPIC\",
            \"show_name\": \"$SHOW_NAME\",
            \"enrichment_type\": \"comprehensive\"
        }")

    # Check if response contains success
    if echo "$response" | grep -q '"enrichment_complete":true'; then
        print_success "Perplexity AI Enrichment works correctly"
        queries=$(echo "$response" | jq -r '.data.queries_processed')
        print_info "Processed $queries queries"
    else
        print_error "Perplexity AI Enrichment failed"
        echo "$response" | jq '.'
    fi
}

test_pinecone_indexer() {
    print_header "Testing Pinecone Indexer"

    print_info "Indexing sample data..."

    response=$(curl -s -X POST "$N8N_WEBHOOK_URL/index-to-pinecone" \
        -H "Content-Type: application/json" \
        -d "{
            \"data\": {
                \"character_name\": \"Test Character\",
                \"character_bio\": \"This is a test character for indexing.\",
                \"relationships\": \"None\"
            },
            \"data_type\": \"fandom_wiki\",
            \"show_name\": \"Test Show\",
            \"namespace\": \"research-data\"
        }")

    # Check if response contains success
    if echo "$response" | grep -q '"success":true'; then
        print_success "Pinecone Indexer works correctly"
        vectors=$(echo "$response" | jq -r '.vectors_indexed')
        print_info "Indexed $vectors vectors"
    else
        print_error "Pinecone Indexer failed"
        echo "$response" | jq '.'
    fi
}

test_research_agent() {
    print_header "Testing Research Agent"

    print_info "Querying research for: $VIDEO_TOPIC..."

    response=$(curl -s -X POST "$N8N_WEBHOOK_URL/research-query" \
        -H "Content-Type: application/json" \
        -d "{
            \"video_topic\": \"$VIDEO_TOPIC\",
            \"show_name\": \"$SHOW_NAME\",
            \"query_type\": \"comprehensive\",
            \"top_k\": 5
        }")

    # Check if response contains success
    if echo "$response" | grep -q '"success":true'; then
        print_success "Research Agent works correctly"
        total_results=$(echo "$response" | jq -r '.research_data.total_results')
        print_info "Retrieved $total_results results"
    else
        print_error "Research Agent failed"
        echo "$response" | jq '.'
    fi
}

test_orchestrator_query() {
    print_header "Testing Orchestrator - Research Query"

    print_info "Running orchestrated research query..."

    response=$(curl -s -X POST "$N8N_WEBHOOK_URL/research-layer/orchestrate" \
        -H "Content-Type: application/json" \
        -d "{
            \"operation\": \"research_query\",
            \"show_name\": \"$SHOW_NAME\",
            \"video_topic\": \"$VIDEO_TOPIC\"
        }")

    # Check if response contains success
    if echo "$response" | grep -q '"success":true'; then
        print_success "Orchestrator (Research Query) works correctly"
    else
        print_error "Orchestrator (Research Query) failed"
        echo "$response" | jq '.'
    fi
}

test_orchestrator_enrichment() {
    print_header "Testing Orchestrator - Direct Enrichment"

    print_info "Running orchestrated enrichment..."

    response=$(curl -s -X POST "$N8N_WEBHOOK_URL/research-layer/orchestrate" \
        -H "Content-Type: application/json" \
        -d "{
            \"operation\": \"enrich_data\",
            \"show_name\": \"$SHOW_NAME\",
            \"video_topic\": \"$VIDEO_TOPIC\"
        }")

    # Check if response contains success
    if echo "$response" | grep -q '"enrichment_complete":true'; then
        print_success "Orchestrator (Enrichment) works correctly"
    else
        print_error "Orchestrator (Enrichment) failed"
        echo "$response" | jq '.'
    fi
}

# Performance test
test_performance() {
    print_header "Performance Test"

    print_info "Testing response time for research query..."

    start_time=$(date +%s%N)

    curl -s -X POST "$N8N_WEBHOOK_URL/research-query" \
        -H "Content-Type: application/json" \
        -d "{
            \"video_topic\": \"$VIDEO_TOPIC\",
            \"show_name\": \"$SHOW_NAME\",
            \"query_type\": \"comprehensive\",
            \"top_k\": 5
        }" > /dev/null

    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 ))

    if [ $duration -lt 5000 ]; then
        print_success "Response time: ${duration}ms (excellent)"
    elif [ $duration -lt 10000 ]; then
        print_success "Response time: ${duration}ms (good)"
    else
        print_info "Response time: ${duration}ms (acceptable)"
    fi
}

# Main test suite
main() {
    print_header "Research Layer Test Suite"
    print_info "Testing endpoint: $N8N_WEBHOOK_URL"
    print_info "Show: $SHOW_NAME"
    print_info "Wiki: $WIKI_URL"
    echo ""

    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        print_error "jq is not installed. Please install jq to run tests."
        exit 1
    fi

    # Run tests
    test_fandom_scraper
    test_perplexity_enrichment
    test_pinecone_indexer
    test_research_agent
    test_orchestrator_query
    test_orchestrator_enrichment
    test_performance

    # Summary
    print_header "Test Summary"
    echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        print_success "All tests passed! 🎉"
        exit 0
    else
        print_error "Some tests failed. Please review the output above."
        exit 1
    fi
}

# Run main if script is executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
