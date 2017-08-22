require 'rest-client'
require 'json'
require 'httparty'

REPO_URL="example/example"

def get_issues_by_label(label_name)
  output = ''
  output += "### #{label_name.capitalize}\n"
  response = RestClient.get('https://api.github.com/repos/'+REPO_URL+'/issues?labels='+label_name)
  issues = JSON.parse(response)
  output += "- None found\n" if issues.empty?
  issues.each do |issue|
    output += "- [#{issue['title']}](#{issue['url']})\n"
  end
  return output
end

def main
  output = ''
  output += get_issues_by_label('minor')
  output += get_issues_by_label('moderate')
  output += get_issues_by_label('major')
  output += get_issues_by_label('critical')
  File.open('output.md', 'w') { |file| file.write(output) }
end

main
