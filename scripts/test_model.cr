#!/usr/bin/env crystal

require "cadmium_classifier"

# Load the trained sentiment model
model_path = "models/sentiment/sentiment_twitter.model"

puts "🔍 Testing Model Loading..."
puts "📂 Model: #{model_path}"
puts ""

# Load from MessagePack binary
bytes = File.read(model_path)
classifier = Cadmium::Classifier::Bayes.from_msgpack(bytes)

puts "✅ Model loaded successfully!"
puts "📊 Vocabulary size: #{classifier.vocabulary_size}"
puts "📄 Total documents: #{classifier.total_documents}"
puts "🏷️  Categories: #{classifier.categories.join(", ")}"
puts ""

# Test predictions
test_sentences = [
  "I absolutely love this new feature! It's amazing!",
  "This is the worst experience I've ever had.",
  "Just had lunch. It was okay.",
  "Can't wait for the weekend! Going to be so much fun!",
  "My car broke down again. So frustrated right now.",
]

puts "🧪 Testing predictions:"
puts ""

test_sentences.each do |text|
  result = classifier.classify(text)
  top_category = classifier.classify_category(text)
  confidence = result[top_category]

  puts "Text: \"#{text}\""
  puts "  → #{top_category} (confidence: #{confidence.round(2)}%)"
  puts ""
end

puts "✅ Model testing complete!"
