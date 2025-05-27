# == Schema Information
#
# Table name: posts
#
#  id          :integer          not null, primary key
#  title       :string
#  body        :string
#  views_count :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Post < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name "my_custom_post_index"

  has_many :comments, dependent: :destroy

  settings analysis: {
    "filter": {
      "custom_synonym_filter": {
        "type": "synonym",
        "synonyms": [
          "may tinh => laptop",
        ]
      }
    },
    analyzer: {
      asciifolding_custom: {
        type:      'custom',
        tokenizer: 'standard',
        filter:    %w[lowercase asciifolding custom_synonym_filter]
      }
    }
  }

  mapping do
    indexes :id, type: :integer
    indexes :title, type: :text, analyzer: 'asciifolding_custom'
    indexes :body, type: :text, analyzer: 'snowball'
    indexes :comments do
      indexes :id, type: :integer
      indexes :body, type: :text
    end
  end

  def as_indexed_json(_options = {})
    as_json(
      methods: %i[custom_post_method],
      # include: [:comments],
      include: {
        comments: { only: [:id, :body] },
      }
    )
  end

  def custom_post_method
    self.title.split.first
  end

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: %w[title body]
          }
        }
      }
    )
  end

  # def self.search(query)
  #   __elasticsearch__.search(
  #     {
  #       query: {
  #         multi_match: {
  #           query: query,
  #           fields: %w[title body],
  #           "fuzziness": 1
  #         }
  #       }
  #     }
  #   )
  # end
end
