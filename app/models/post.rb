# == Schema Information
#
# Table name: posts
#
#  id         :integer          not null, primary key
#  title      :string
#  body       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Post < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name "my_custom_post_index"

  has_many :comments, dependent: :destroy

  settings analysis: {
    analyzer: {
      asciifolding_lowercase: {
        type:      'custom',
        tokenizer: 'standard',
        filter:    %w[lowercase asciifolding]
      },
      keyword:           {
        type:      'custom',
        tokenizer: 'keyword',
        filter:    []
      },
      lowercase:         {
        type:      'custom',
        tokenizer: 'standard',
        filter:    ['lowercase']
      }
    }
  }

  mapping do
    indexes :id, type: :integer
    indexes :title, type: :text, analyzer: 'asciifolding_lowercase'
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
end
