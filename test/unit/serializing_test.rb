require 'test_helper'

class SerializingTest < MiniTest::Test

  class LimitedField < TestResource
    self.read_only_attributes += ['foo']
  end

  def test_update_data_only_includes_relationship_data
    stub_request(:get, "http://example.com/articles")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          attributes: {
            title: "JSON API paints my bikeshed!"
          },
          relationships: {
            author: {
              links: {
                self: "http://example.com/posts/1/relationships/author",
                related: "http://example.com/posts/1/author"
              },
              data: {
                type: "people",
                id: "9"
              }
            }
          }
        }],
        included: [{
          type: "people",
          id: "9",
          attributes: {
            name: "Jeff"
          }
        }]
      }.to_json)

    articles = Article.all
    article = articles.first

    expected = {
      "type" => "articles",
      "id" => "1",
      "attributes" => {
        "title" => "JSON API paints my bikeshed!"
      },
      "relationships" => {
        "author" => {
          "data" => {
            "type" => "people",
            "id" => "9"
          }
        }
      }
    }
    assert_equal expected, article.serializable_hash
  end

  def test_skips_read_only_attributes
    resource = LimitedField.new({
      id: 1,
      foo: "bar",
      qwer: "asdf"
    })

    expected = {
      'id' => 1,
      'type' => 'limited_fields',
      'attributes' => {
        'qwer' => 'asdf'
      }
    }
    assert_equal(expected, resource.serializable_hash)
  end

end