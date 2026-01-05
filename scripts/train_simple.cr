#!/usr/bin/env crystal

require "cadmium_classifier"

# Simple training script for sentiment analysis model
# Usage: crystal run scripts/train_simple.cr -- <training_data.txt> <output_name>

data_file = ARGV[0]? || "training_data.txt"
output_name = ARGV[1]? || "sentiment_twitter"

puts "🚀 Starting model training..."
puts "📄 Data file: #{data_file}"

# Initialize classifier
classifier = Cadmium::Classifier::Bayes.new

# Read and shuffle data
all_data = Array(Tuple(String, String)).new
File.each_line(data_file) do |line|
  next if line.strip.empty?
  parts = line.split("\t")
  if parts.size >= 2
    text = parts[0..-2].join("\t")
    category = parts[-1]
    all_data << {text, category}
  end
end

puts "📚 Total samples: #{all_data.size}"
puts ""

# Shuffle data
all_data.shuffle!

# Split 80/20 train/test
split_index = (all_data.size * 0.8).to_i
train_data = all_data[0...split_index]
test_data = all_data[split_index..]

puts "📚 Training samples: #{train_data.size}"
puts "🧪 Test samples: #{test_data.size}"
puts ""

# Train
puts "⏳ Training..."
train_start = Time.monotonic

train_data.each do |text, category|
  classifier.train(text, category)
end

train_time = Time.monotonic - train_start
puts "✅ Training completed in #{train_time.total_seconds.round(2)} seconds"
puts ""

# Evaluate
puts "📈 Evaluating on test set..."
correct = 0
confusion_matrix = Hash(String, Hash(String, Int32)).new { |h, k| h[k] = Hash(String, Int32).new(0) }

test_data.each do |text, actual_category|
  predicted = classifier.classify_category(text)
  confusion_matrix[actual_category][predicted] += 1
  correct += 1 if predicted == actual_category
end

accuracy = correct.to_f / test_data.size
puts "📊 Accuracy: #{(accuracy * 100).round(2)}%"
puts ""

# Per-category metrics
puts "📋 Per-category metrics:"
categories = confusion_matrix.keys
categories.each do |category|
  tp = confusion_matrix[category][category]
  fp = categories.sum { |c| c == category ? 0 : confusion_matrix[c][category] }
  fn = categories.sum { |c| c == category ? 0 : confusion_matrix[category][c] }

  precision = tp.to_f / (tp + fp) rescue 0.0
  recall = tp.to_f / (tp + fn) rescue 0.0
  f1 = 2 * precision * recall / (precision + recall) rescue 0.0

  puts "  #{category}:"
  puts "    Precision: #{(precision * 100).round(2)}%"
  puts "    Recall: #{(recall * 100).round(2)}%"
  puts "    F1 Score: #{(f1 * 100).round(2)}%"
end
puts ""

# Confusion matrix
puts "🔢 Confusion Matrix:"
categories.each do |actual|
  print "  #{actual}: "
  categories.each do |predicted|
    print "#{confusion_matrix[actual][predicted]}\t"
  end
  puts ""
end
puts ""

# Export model
puts "💾 Exporting model..."
model_file = "#{output_name}.model"
json_file = "#{output_name}.model.json"

# Export as MessagePack
bytes = classifier.to_msgpack
File.write(model_file, bytes)
puts "✅ Model exported to: #{model_file}"
puts "📦 Size: #{bytes.size} bytes"

# Export JSON as fallback
File.write(json_file, classifier.to_json)
puts "✅ JSON fallback exported to: #{json_file}"
puts ""

# Generate metadata
puts "📝 Generating metadata.yml..."
metadata = String.build do |yaml|
  yaml << "---\n"
  yaml << "name: sentiment\n"
  yaml << "version: 1.0.0\n"
  yaml << "description: Twitter sentiment analysis model trained on Sentiment140 data\n"
  yaml << "model_type: Bayes\n"
  yaml << "\n"
  yaml << "trained_on:\n"
  yaml << "  - dataset: Sentiment140\n"
  yaml << "    size: #{all_data.size}\n"
  yaml << "    source: http://thinknook.com/wp-content/uploads/2012/09/Sentiment-Analysis-Dataset.zip\n"
  yaml << "    license: Other\n"
  yaml << "\n"
  yaml << "categories:\n"
  categories.sort.each do |cat|
    yaml << "  - #{cat}\n"
  end
  yaml << "\n"
  yaml << "vocabulary_size: #{classifier.vocabulary_size}\n"
  yaml << "training_documents: #{train_data.size}\n"
  yaml << "\n"
  yaml << "# Performance metrics\n"
  yaml << "accuracy: #{accuracy.round(4)}\n"
  yaml << "\n"
  yaml << "precision:\n"
  categories.each do |cat|
    tp = confusion_matrix[cat][cat]
    fp = categories.sum { |c| c == cat ? 0 : confusion_matrix[c][cat] }
    precision_val = tp.to_f / (tp + fp) rescue 0.0
    yaml << "  #{cat}: #{precision_val.round(4)}\n"
  end
  yaml << "\n"
  yaml << "recall:\n"
  categories.each do |cat|
    tp = confusion_matrix[cat][cat]
    fn = categories.sum { |c| c == cat ? 0 : confusion_matrix[cat][c] }
    recall_val = tp.to_f / (tp + fn) rescue 0.0
    yaml << "  #{cat}: #{recall_val.round(4)}\n"
  end
  yaml << "\n"
  yaml << "f1_score:\n"
  categories.each do |cat|
    tp = confusion_matrix[cat][cat]
    fp = categories.sum { |c| c == cat ? 0 : confusion_matrix[c][cat] }
    fn = categories.sum { |c| c == cat ? 0 : confusion_matrix[cat][c] }
    precision = tp.to_f / (tp + fp) rescue 0.0
    recall = tp.to_f / (tp + fn) rescue 0.0
    f1 = 2 * precision * recall / (precision + recall) rescue 0.0
    yaml << "  #{cat}: #{f1.round(4)}\n"
  end
  yaml << "\n"
  yaml << "# Language and locale\n"
  yaml << "language: en\n"
  yaml << "\n"
  yaml << "# Licensing\n"
  yaml << "license: Other\n"
  yaml << "\n"
  yaml << "# Metadata\n"
  yaml << "author: Cadmium Contributors\n"
  yaml << "created_at: #{Time.utc.to_s("%Y-%m-%d")}\n"
  yaml << "\n"
  yaml << "# Version requirements\n"
  yaml << "cadmium_version: \">= 0.2.0\"\n"
  yaml << "\n"
  yaml << "# Tags for discoverability\n"
  yaml << "tags:\n"
  yaml << "  - sentiment\n"
  yaml << "  - social-media\n"
  yaml << "  - twitter\n"
  yaml << "  - english\n"
  yaml << "\n"
  yaml << "# Training configuration\n"
  yaml << "training_config:\n"
  yaml << "  test_split: 0.2\n"
  yaml << "  training_time_seconds: #{train_time.total_seconds.round(2)}\n"
  yaml << "  trained_at: #{Time.utc.to_s("%Y-%m-%dT%H:%M:%SZ")}\n"
end

metadata_file = "metadata.yml"
File.write(metadata_file, metadata)
puts "✅ Metadata saved to: #{metadata_file}"
puts ""

puts "🎉 Training complete!"
puts ""
puts "📦 Generated files:"
puts "  - #{model_file}"
puts "  - #{json_file}"
puts "  - #{metadata_file}"
