
require "pathname"
require "vcardigan"

unless ARGV[0]
  puts "Pass in a VCF file to extract and write only contacts with telephone numbers"
  exit
end

lines = ARGF.read 
vcf_directory_path = File.dirname(File.expand_path(ARGF.path))
vcf_file_name = File.basename(ARGF.path).gsub(File.extname(ARGF.path),"")
vcf_converted_file_name = "#{vcf_file_name}-filtered.vcf"

vcf_converted_file_path = Pathname.new(vcf_directory_path).join(vcf_converted_file_name).to_s

lines_array = lines.split("\r\nEND:VCARD\r\n").map { |t| "#{t}\r\nEND:VCARD\r\n" }
tel_lines_array = lines.split("\r\nEND:VCARD\r\n").map { |t| "#{t}\r\nEND:VCARD\r\n" }.select { |t| t.include? "TEL" }

puts "Extracted #{tel_lines_array.count} contacts with telephone numbers from #{lines_array.count} contacts"

tel_lines = tel_lines_array.join("")

File.open(vcf_converted_file_path, "w") do |f|
  f.write(tel_lines)
end

puts "Wrote to #{vcf_converted_file_path}"

puts "Verifying..."

lines = File.open(vcf_converted_file_path) { |f| f.read }
lines_array = lines.split("\r\nEND:VCARD\r\n").map { |t| "#{t}\r\nEND:VCARD\r\n" }
errors = 0
success = 0

lines_array.each do |line|
  begin
    print "."
    success += 1
    VCardigan.parse(line.chomp)
  rescue NoMethodError => e
    errors += 1
    print "E"
  end
end

puts "\nVerified #{success} contacts, #{errors} in error."