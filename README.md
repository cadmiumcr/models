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

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Training new models
- Submitting models for inclusion
- Model versioning and release process

## License

Models are released under the MIT license unless otherwise noted in individual model metadata.

## Links

- [Cadmium NLP Library](https://github.com/cadmiumcr/cadmium)
- [Classifier Documentation](https://github.com/cadmiumcr/classifier)
