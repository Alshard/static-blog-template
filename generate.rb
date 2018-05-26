$LOAD_PATH << '.'
require 'php_generator.rb'

def get_next_chapter_num(title)
  begin
    file = 'translations/' + title + '/chapter_list.txt'
    f = File.open(file, 'r')
    count = 1
    while (f.gets)
      f.gets
      count += 1
    end
    f.close
    return count
  rescue => err
    puts "Exception: #{err}"
    err
  end
end

def generate_all_chapters
  gen = ChapterPHPGenerator.new('translations/example/chapter_list.txt', 'example')
  len = gen.chapters
  (1..len).each do |x|
    gen.create_chapter_post(x.to_s)
  end
end

begin
  gen = ChapterPHPGenerator.new('translations/example/chapter_list.txt', 'example')
  puts gen.chapters
  gen.create_main_page
  generate_all_chapters
end
