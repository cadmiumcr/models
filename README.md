# Cadmium Models

Pre-trained machine learning models for the Cadmium NLP library.

## Overview

This repository contains pre-trained models that can be easily loaded and used with Cadmium classifiers and other NLP components. Models are stored in efficient binary format (MessagePack) for fast loading and minimal storage.

## Model Formats

Each model may include:
- `.model` - Binary MessagePack format (recommended, fastest loading)
- `.model.json` - JSON format (human-readable, fallback)
- `metadata.yml` - Model information, training data stats, accuracy metrics

## Usage

### Loading a Model

```crystal
require "cadmium_classifier"

# Load from binary format (fastest)
bytes = File.read("path/to/model.model")
classifier = Cadmium::Classifier::Bayes.from_msgpack(bytes)

# Or load from JSON
classifier = Cadmium::Classifier::Bayes.from_json(File.read("path/to/model.model.json"))

# Use the classifier
result = classifier.classify("Your text here")
```

## Available Models

### Sentiment Analysis
- **sentiment_twitter** - English sentiment classification (positive/negative)
  - Trained on: Sentiment140 Twitter dataset (50K samples, 40K for training)
  - Accuracy: 75.05%
  - Precision: 79.04% (positive), 71.04% (negative)
  - Recall: 73.29% (positive), 77.12% (negative)
  - F1 Score: 76.06% (positive), 73.95% (negative)
  - Categories: 2 (positive, negative)
  - Vocabulary: 59,982 words
  - Training time: 1.12 seconds
  - Source: http://thinknook.com/wp-content/uploads/2012/09/Sentiment-Analysis-Dataset.zip

#### Example Usage

```crystal
require "cadmium_classifier"

# Load the model
bytes = File.read("models/sentiment/sentiment_twitter.model")
classifier = Cadmium::Classifier::Bayes.from_msgpack(bytes)

# Classify text
result = classifier.classify("I love this new feature!")
# => {"positive" => 96.67, "negative" => 3.33}

# Get just the top category
category = classifier.classify_category("This is terrible!")
# => "negative"
```

## Creating Models

### Quick Start

The simplest way to train a new model:

```bash
# Prepare your training data (tab-separated: text<TAB>category)
cat > data/training_data.txt << EOF
I love this product!	positive
This is terrible.	negative
Amazing experience!	positive
Worst service ever	negative
EOF

# Train the model
crystal run src/cadmium_models.cr train data/training_data.txt my_model

# Move generated files to models directory
mv my_model.model my_model.model.json metadata.yml models/<category>/
```

### Training Data Format

Training data must be tab-separated with the text content first and the category last:

```
Text content here	category1
Another text sample	category2
Multi-word text here	category1
```

**Important:** Use tabs (`\t`) to separate the text from the category, not commas or spaces.

### Training CLI

The CLI provides a simple interface for training models:

```bash
crystal run src/cadmium_models.cr train <data_file> <model_name>
```

**Features:**
- Automatic 80/20 train/test split
- Computes accuracy, precision, recall, F1 scores
- Generates confusion matrix
- Auto-creates metadata.yml with all metrics
- Exports both MessagePack and JSON formats

**Example:**
```bash
crystal run src/cadmium_models.cr train data/spam_data.txt spam_detector
```

**Output:**
```
🚀 Starting model training...
📚 Total samples: 10000
📚 Training samples: 8000
🧪 Test samples: 2000
⏳ Training...
✅ Training completed in 0.45 seconds
📊 Accuracy: 98.2%
📦 Generated files:
  - spam_detector.model (245 KB)
  - spam_detector.model.json (312 KB)
  - metadata.yml
```

### Testing Your Model

After training, verify your model works correctly:

```bash
crystal run src/cadmium_models.cr test models/sentiment/sentiment_twitter.model
```

This will load the model and run sample predictions to verify it's working.

### Model File Organization

Organize trained models by category:

```
models/
├── sentiment/
│   ├── sentiment_twitter.model
│   ├── sentiment_twitter.model.json
│   └── metadata.yml
├── spam/
│   ├── email_spam.model
│   ├── email_spam.model.json
│   └── metadata.yml
└── language/
    ├── lang_detector.model
    ├── lang_detector.model.json
    └── metadata.yml
```

### Best Practices

1. **Data Quality** - Use clean, labeled data. Remove duplicates and obvious errors.
2. **Dataset Size** - More data is generally better, but 10K-50K samples is often sufficient for good results.
3. **Balanced Classes** - Try to have roughly equal samples per category for best accuracy.
4. **Test Split** - Always reserve 20-30% of data for testing to validate performance.
5. **Metadata** - Keep metadata.yml accurate and complete for model discoverability.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Submitting models for inclusion
- Model versioning and release process
- Code quality standards

## License

Models are released under the MIT license unless otherwise noted in individual model metadata.

## Links

- [Cadmium NLP Library](https://github.com/cadmiumcr/cadmium)
- [Classifier Documentation](https://github.com/cadmiumcr/classifier)
