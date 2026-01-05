# Contributing to Cadmium Models

Thank you for your interest in contributing pre-trained models to the Cadmium Models repository!

## Overview

This repository hosts pre-trained NLP models for the Cadmium library. Models should be well-documented, properly tested, and include performance metrics.

## Model Submission Guidelines

### 1. Model Quality

- **Accuracy**: Models should achieve reasonable performance for their task
- **Dataset**: Use well-known, publicly available datasets when possible
- **Testing**: Include test predictions demonstrating model behavior
- **Documentation**: Complete metadata.yml with training details

### 2. Required Files

Each model submission must include:

```
models/<category>/<model_name>/
├── <model_name>.model          # MessagePack binary format
├── <model_name>.model.json     # JSON fallback format
└── metadata.yml                # Model information and metrics
```

### 3. Metadata Schema

The `metadata.yml` file must include:

```yaml
name: model_name
version: 1.0.0
description: Brief description of what the model does
model_type: Bayes  # or other classifier types

trained_on:
  - dataset: Dataset name
    size: 50000
    source: URL or citation
    license: License of the training data

categories:
  - category1
  - category2

vocabulary_size: 15000
training_documents: 40000

# Performance metrics
accuracy: 0.85

precision:
  category1: 0.87
  category2: 0.83

recall:
  category1: 0.85
  category2: 0.86

f1_score:
  category1: 0.86
  category2: 0.84

language: en
license: MIT
author: Your Name
created_at: 2025-01-05
cadmium_version: ">= 0.2.0"

tags:
  - tag1
  - tag2
  - english

training_config:
  test_split: 0.2
  training_time_seconds: 1.5
  trained_at: 2025-01-05T12:00:00Z
```

### 4. Training New Models

Use the provided training scripts:

```bash
# Simple training script
crystal run scripts/train_simple.cr -- training_data.txt model_name

# Full-featured training with options
crystal run scripts/train_model.cr -- --data training_data.txt --output my_model --categories cat1,cat2
```

#### Training Data Format

Training data should be tab-separated:
```
Text content here	category1
Another text sample	category2
```

### 5. Testing Your Model

Before submitting, test your model:

```bash
crystal run scripts/test_model.cr
```

Verify:
- Model loads correctly
- Predictions are reasonable
- Performance metrics are documented

## Model Categories

We welcome models in these areas:

- **Sentiment Analysis** - emotion, opinion, sentiment classification
- **Spam Detection** - spam vs ham classification
- **Language Detection** - language identification
- **Topic Classification** - categorizing text by topic
- **Intent Classification** - user intent detection
- **Content Moderation** - detecting inappropriate content

## Submission Process

1. **Train your model** using the provided scripts
2. **Test thoroughly** - verify accuracy and reasonable predictions
3. **Create metadata.yml** - fill in all required fields
4. **Place in appropriate directory** - `models/<category>/`
5. **Submit a pull request** - include description of your model

## Review Criteria

Submissions will be reviewed based on:

- Model accuracy and performance
- Quality of training data
- Completeness of metadata
- Documentation quality
- Code quality (for custom training scripts)

## Model Versioning

When updating an existing model:

1. Increment the version in `metadata.yml`
2. Document improvements in the PR description
3. Keep previous versions until the new one is validated

## License

By submitting models, you agree to release them under the MIT License. Ensure your training data license is compatible.

## Questions?

Open an issue with the `question` label for any questions about contributing.
