#!/usr/bin/env ruby

license_groups = {}
File.readlines('/usr/portage/profiles/license_groups').each do |line|
  next unless line =~ /^[a-zA-Z]/
  group, licenses = line.split(' ', 2)
  license_groups["@#{group}"] = licenses.split(' ').map do |license|
    license.start_with?('@') ? license_groups[license] : license
  end.flatten
end

package_license_files = Dir['/var/db/pkg/*/*/LICENSE']
package_count = package_license_files.count
nonfree_count = 0
package_license_files.each do |package_license_file|
  package_licenses = File.read(package_license_file).split(' ') - ['(', ')', '||']
  unless package_licenses.all? { |pl| license_groups['@FREE'].include?(pl) }
    puts "Unfree package found: #{package_license_file} => [#{package_licenses.join(',')}]"
    nonfree_count += 1
  end
end

freedom_index = 100 * (package_count - nonfree_count).to_f / package_count.to_f

puts
puts "Your GNU/Linux is infected with #{nonfree_count} non-free packages out of #{package_count} total installed."
puts "Your Stallman Freedom Index is #{'%0.2f' % freedom_index}"
