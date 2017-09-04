require 'rest-client'
require 'json'
require 'httparty'

REPO_URL="example/example"
ISSUE_LABELS = ['minor', 'moderate', 'major', 'critical']

# These are optional, it increases your github API limit when used
CLIENT_ID = ''
CLIENT_SECRET = ''

def get_issues_by_label(label_name)
  output = ''
  output += "### #{label_name.capitalize}\n"

  git_url = 'https://api.github.com/repos/'+REPO_URL+'/issues?labels='+label_name
  git_url += "&client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}" unless CLIENT_ID.empty?

  issues = JSON.parse(RestClient.get(git_url))

  output += "- None found\n" if issues.empty?
  issues.each do |issue|
    new_body = ''
    words = issue['body'].split(' ').each do |word|
      if word.start_with? 'https://github.com'
        line_number = word[word.index('#')..-1]
        word = "[#{line_number}](#{word}])"
      end
      new_body << "#{word} "
      break if new_body.size > 150
    end
    issue_body = new_body + (new_body.size > 150 ? '...' : '')
    labels = []
    issue['labels'].each do |label|
      labels << label['name'].capitalize unless ISSUE_LABELS.include? label['name']
    end
    labels_text = ''
    labels_text = '`' + labels.join('`, ') + '`' unless labels.empty?
    output += "- **#{issue['title']}** - #{labels_text} #{issue_body} [View on GitHub](#{issue['html_url']})\n"
  end
  return output
end

def main
  output = ''
  ISSUE_LABELS.each do |issue_label|
    output += get_issues_by_label(issue_label)
  end
  File.open('output.md', 'w') { |file| file.write(output) }
end

main
