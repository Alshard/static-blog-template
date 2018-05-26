# write the html code before content to a file
def write_pre_content(title, header, subheading, date, targetFile)
  begin
    f = File.open(targetFile, 'w')
    f.write("
  <?php echo file_get_contents($_SERVER['DOCUMENT_ROOT'].'/template/pre_title.php'); ?>
  <title>" + title + "</title>
  <?php echo file_get_contents($_SERVER['DOCUMENT_ROOT'].'/template/post_title.php'); ?>

  <?php echo file_get_contents($_SERVER['DOCUMENT_ROOT'].'/template/pre_header.php'); ?>
    <h1>" + header + "</h1>
    <h2 class='subheading'>" + subheading + "</h2>
    <span class='meta'>" + date + "</span>
  <?php echo file_get_contents($_SERVER['DOCUMENT_ROOT'].'/template/post_header.php'); ?>
  <?php echo file_get_contents($_SERVER['DOCUMENT_ROOT'].'/template/pre_content.php'); ?>")
    f.close
  rescue => err
    puts "Exception: #{err}"
    err
  end
end

# write the html code after content to a file
def write_post_content(targetFile)
  begin
    f = File.open(targetFile, 'a')
    f.write("<?php echo file_get_contents($_SERVER['DOCUMENT_ROOT'].'/template/post_content.php'); ?>")
    f.close
  rescue => err
    puts "Exception: #{err}"
    err
  end
end

def write_markdown_content(sourceFile, targetFile)
  begin
    f = File.open(targetFile, 'a')
    f.write(
      "<?php
    // convert markdown to html and insert as content
    include($_SERVER['DOCUMENT_ROOT'].'/Parsedown.php');
    $Parsedown = new Parsedown();
    echo $Parsedown->text(file_get_contents($_SERVER['DOCUMENT_ROOT'].'/" + sourceFile + "'));
  ?>"
    )
    f.close
  rescue => err
    puts "Exception: #{err}"
    err
  end
end

# represents posts using a name and date
class Post
  def initialize(post, date)
    @post = post.rstrip
    @date = date
    @link = post.clone
    @link.gsub! ' ', '%20'
    @link = @link + ".php"
  end

  attr_reader :post
  attr_reader :date
  attr_reader :link
end

# generator for creating php files
class ChapterPHPGenerator
  def initialize(list, title)
    @title = title
    @listItems = Array.new

    f = File.open(list, 'r')
    while (post = f.gets)
      date = f.gets
      @listItems.push(Post.new(post, date))
    end
  end

  def chapters
    return @listItems.length
  end

  def insert_prev_next_chapter_links(dir, index)
    index = index.to_i
    index -= 1
    div = "<div class='chapterNav'>"
    f = File.open(dir + @listItems[index].post + ".php", 'a')
    if index > 0
      prev = @listItems[index - 1]
      div << "<a href='" + prev.link + "'>" + prev.post + "</a> | "
    end

    div << "<a href='main.php'>Main Page</a>"

    if index < @listItems.length - 2
      n = @listItems[index + 1]
      div << " | <a href='" + n.link + "'>" + n.post + "</a>"
    end

    div << "</div>"
    f.write(div)
    f.close
  end

  def create_chapter_post(chapterNum)
    sourceFile = "translations/" + @title + "/" + chapterNum.to_s + ".md"
    dir = "translations/" + @title + "/php/"
    chapterName = @listItems[chapterNum.to_i - 1].post
    targetFile = dir + chapterName.to_s + ".php"

    time = Time.new
    time = time.strftime("%d/%m/%Y")
    write_pre_content(@title + ' - ' + chapterName.to_s, @title, chapterName.to_s, time, targetFile)
    write_markdown_content(sourceFile, targetFile)

    # insert links to the previous and next chapters
    insert_prev_next_chapter_links(dir, chapterNum)

    write_post_content(targetFile)
  end

  def create_main_page
    chapterList = "translations/" + @title + "/chapter_list.txt"
    dir = "translations/" + @title + "/php/"
    file = dir + "main.php"

    time = Time.new
    time = time.strftime("%d/%m/%Y")

    write_pre_content(@title, 'header', 'subheading', time, file)

    begin
      list = File.open(chapterList, 'r')
      contents = "<table class='tableOfContents'><tr><th>Chapter</th><th>Date</th></tr>"

      count = 1
      while(chapter = list.gets)
        date = list.gets
        chapterName = chapter.clone
        chapter.gsub! ' ', '%20'
        contents << "\n<tr><th><a href='" + chapter + ".php'>" + chapterName + "</a></th><th>" + date + "</th></tr>"
        count += 1
      end
      list.close

      f = File.open(file, 'a')
      f.write(contents)
      f.write("</table>")
      f.close
    rescue => err
      puts "Exception: #{err}"
      err
    end
    write_post_content(file)
  end
end
