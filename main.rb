require 'rest-client'
require 'json'
require 'httparty'

REPO_URL="blockchainlabsnz/wings-private-contracts"
ISSUE_LABELS = ['minor', 'moderate', 'major', 'critical']

# These are optional, it increases your github API limit when used
CLIENT_ID = ''
CLIENT_SECRET = ''

# Personal Access Token is required to auth on private repos
ACCESS_TOKEN = ''

CHARS_PER_ISSUE = 500

def get_issues_by_label(label_name)
  output = ''
  output += "### #{label_name.capitalize}\n"

  git_url = 'https://api.github.com/repos/'+REPO_URL+'/issues?state=all&labels='+label_name
  git_url += "&access_token=#{ACCESS_TOKEN}" unless ACCESS_TOKEN.empty?

  issues = JSON.parse(RestClient.get(git_url))

  output += "- None found\n" if issues.empty?
  issues.each do |issue|
    new_body = ''
    words = issue['body'].split(' ').each do |word|
      if word.start_with? 'https://github.com'
        word = ''
        if word.index('#')
          line_number = word[word.index('#')..-1]
          word = "[#{line_number}](#{word}])"
        end
      end
      new_body << "#{word} "
      break if new_body.size > CHARS_PER_ISSUE
    end
    issue_body = new_body + (new_body.size > CHARS_PER_ISSUE ? '...' : '')
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
  file_name = 'output.md'
  File.open(file_name, 'w') { |file| file.write(output) }
  p "File written to ./#{file_name}"

end

main
