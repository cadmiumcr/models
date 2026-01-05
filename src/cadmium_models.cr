#!/usr/bin/env crystal

require "cadmium_classifier"

module Cadmium::Models
  VERSION = "0.1.0"

  # Base CLI module
  module CLI
    def self.run(args)
      if args.empty?
        print_usage
        exit 1
      end

      command = args[0]

      case command
      when "train"
        run_train(args[1..])
      when "test"
        run_test(args[1..])
      when "-h", "--help", "help"
        print_usage
      else
        puts "Unknown command: #{command}"
        puts ""
        print_usage
        exit 1
      end
    end

    def self.print_usage
      puts "Cadmium Models CLI v#{VERSION}"
      puts ""
      puts "Usage: cadmium_models <command> [options]"
      puts ""
      puts "Commands:"
      puts "  train <data_file> <output_name>    Train a new model"
      puts "  test <model_path>                  Test a trained model"
      puts "  help, -h, --help                   Show this help message"
      puts ""
      puts "Examples:"
      puts "  cadmium_models train training_data.txt sentiment_twitter"
      puts "  cadmium_models test models/sentiment/sentiment_twitter.model"
    end

    # Train command
    def self.run_train(args)
      data_file = args[0]? || "training_data.txt"
      output_name = args[1]? || "sentiment_twitter"

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
      generate_metadata(output_name, classifier, accuracy, confusion_matrix, categories, train_time, all_data.size, train_data.size)

      puts "🎉 Training complete!"
      puts ""
      puts "📦 Generated files:"
      puts "  - #{model_file}"
      puts "  - #{json_file}"
      puts "  - metadata.yml"
    end

    # Generate metadata.yml
    def self.generate_metadata(output_name, classifier, accuracy, confusion_matrix, categories, train_time, total_samples, train_samples)
      puts "📝 Generating metadata.yml..."
      metadata = String.build do |yaml|
        yaml << "---\n"
        yaml << "name: #{output_name}\n"
        yaml << "version: 1.0.0\n"
        yaml << "description: Trained model\n"
        yaml << "model_type: Bayes\n"
        yaml << "\n"
        yaml << "trained_on:\n"
        yaml << "  - dataset: Training data\n"
        yaml << "    size: #{total_samples}\n"
        yaml << "    license: Other\n"
        yaml << "\n"
        yaml << "categories:\n"
        categories.sort.each do |cat|
          yaml << "  - #{cat}\n"
        end
        yaml << "\n"
        yaml << "vocabulary_size: #{classifier.vocabulary_size}\n"
        yaml << "training_documents: #{train_samples}\n"
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
        yaml << "# Training configuration\n"
        yaml << "training_config:\n"
        yaml << "  test_split: 0.2\n"
        yaml << "  training_time_seconds: #{train_time.total_seconds.round(2)}\n"
        yaml << "  trained_at: #{Time.utc.to_s("%Y-%m-%dT%H:%M:%SZ")}\n"
      end

      File.write("metadata.yml", metadata)
      puts "✅ Metadata saved to: metadata.yml"
    end

    # Test command
    def self.run_test(args)
      model_path = args[0]? || "models/sentiment/sentiment_twitter.model"

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
    end
  end
end

# Run the CLI
Cadmium::Models::CLI.run(ARGV)
