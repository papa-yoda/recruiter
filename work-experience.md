# Work Experience

## About This Document

This is a stream-of-consciousness career history. It's intentionally verbose and unpolished — the goal is to capture everything you've done so that Claude can cherry-pick the most relevant achievements for each resume variant.

**Do not clean this up.** More detail is always better. Include numbers, dollar amounts, percentages, team sizes, timelines, and tools used. The resume generation skills will distill this into polished bullet points.

## Work Experience Structure

```
# Company Name
Brief description of the company

## Job Title
Blurb about the role
**Tags:** #relevant-tags

### Date
Start - End

### Projects

#### Project Name
**Tags:** #project-specific-tags
- Bullet points about what you did
- Include quantified results wherever possible
```

## Tagging System

Tags help Claude filter relevant experience for specific job categories. Use any tags that make sense for your field. Examples:

- **Role types:** #frontend, #backend, #fullstack, #management, #design
- **Technical domains:** #react, #python, #aws, #databases, #devops
- **Industries:** #fintech, #healthcare, #ecommerce, #saas
- **Impact types:** #cost-reduction, #performance, #revenue, #user-growth

---

# Nexus Technologies
Series B startup building a developer platform for API management. 200 employees, $40M ARR.

## Senior Software Engineer
Led frontend architecture for the API dashboard product. Managed a team of 3 engineers.
**Tags:** #frontend #react #typescript #leadership #api-platform

### Date
March 2023 - Present

### Projects

#### Dashboard Redesign
**Tags:** #frontend #react #design-system #performance
- Rebuilt the API analytics dashboard from Angular to React/TypeScript, improving page load times by 60% (from 3.2s to 1.3s)
- Designed and implemented a component library (47 components) used across 3 product teams
- Introduced React Query for server state management, reducing API calls by 40% through intelligent caching
- Led user research sessions with 12 enterprise customers to inform the redesign priorities
- Shipped to 2,400+ active users with zero downtime during migration

#### Real-Time Monitoring System
**Tags:** #fullstack #websockets #performance #infrastructure
- Built a real-time API health monitoring system using WebSockets and Redis pub/sub
- Handles 50,000+ events/second across customer deployments
- Reduced mean-time-to-detection for API outages from 8 minutes to 15 seconds
- Integrated with PagerDuty and Slack for automated alerting

## Software Engineer
Individual contributor on the core platform team.
**Tags:** #fullstack #node #postgres #api-design

### Date
June 2021 - March 2023

### Projects

#### API Gateway V2
**Tags:** #backend #node #api-design #microservices
- Redesigned the API gateway to support rate limiting, authentication, and request transformation
- Migrated 800+ customer API configurations with zero breaking changes
- Improved gateway throughput by 3x (from 5K to 15K requests/second) through connection pooling and caching
- Wrote comprehensive API documentation that reduced support tickets by 35%

#### CI/CD Pipeline Overhaul
**Tags:** #devops #automation #testing
- Migrated from Jenkins to GitHub Actions, reducing build times from 45 minutes to 12 minutes
- Implemented automated E2E testing with Playwright, catching 23 regressions in the first quarter
- Set up automated dependency updates with Renovate, keeping all 140+ packages current

---

# Brightfield Analytics
Data analytics company serving the retail industry. 80 employees.

## Full-Stack Developer
Built internal tools and customer-facing dashboards for retail analytics.
**Tags:** #fullstack #python #react #data-visualization #analytics

### Date
January 2019 - May 2021

### Projects

#### Retail Insights Dashboard
**Tags:** #frontend #react #d3 #data-visualization
- Built an interactive data visualization platform using React and D3.js
- Served 150+ retail enterprise clients, displaying $2B+ in aggregated sales data
- Reduced report generation time from 2 hours (manual Excel) to 5 minutes (automated)
- Implemented role-based access control supporting 3 permission tiers

#### ETL Pipeline Modernization
**Tags:** #backend #python #aws #data-engineering
- Migrated legacy batch processing (cron + bash scripts) to Apache Airflow on AWS
- Processed 50GB+ of daily retail transaction data across 12 data sources
- Reduced data pipeline failures from ~15/month to <2/month through better error handling and monitoring
- Cut monthly AWS costs by $4,200 through S3 lifecycle policies and reserved instances

## Junior Developer
First engineering role. Focused on backend services and database management.
**Tags:** #backend #python #sql #databases

### Date
July 2017 - December 2018

### Projects

#### Inventory Sync Service
**Tags:** #backend #python #api-integration
- Built a REST API service to sync inventory data between client POS systems and our analytics platform
- Integrated with 4 POS vendors (Square, Shopify, Lightspeed, Toast)
- Processed 2M+ inventory updates daily with 99.9% reliability
- Designed the database schema (PostgreSQL) handling 500M+ historical records

---

# Education

## B.S. Computer Science
**University of Michigan** — Ann Arbor, MI
August 2013 - May 2017

- GPA: 3.6/4.0
- Teaching Assistant for EECS 281 (Data Structures & Algorithms), 2 semesters
- Senior capstone: Built a distributed task scheduler using Go (team of 4)

---

# Personal Projects

## Open Source Contribution - React Table
- Contributed pagination and virtual scrolling features to react-table v8
- 3 merged PRs, ~400 lines of code, used by 20K+ projects

## Budget Tracker App
- Full-stack personal finance app (Next.js + Supabase)
- Automated bank transaction categorization using rule-based engine
- 50+ active users from friends/family
