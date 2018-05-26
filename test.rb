require 'fileutils'
begin
  num = 10000
  (2..num).each do |x| 
    FileUtils.cp('translations/example/1.md', 'translations/example/' + x.to_s + '.md')
  end

  f = File.open('translations/example/chapter_list.txt', 'w')
  (1..num).each do |i|
    f.write('Chapter ' + i.to_s + "\n")
    f.write('24/5/2018' + "\n")
  end
  f.close
end
