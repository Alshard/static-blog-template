<!-- Title -->
<?php echo file_get_contents('post_template/pre_title.php'); ?>
<title>Some title</title>
<?php echo file_get_contents('post_template/post_title.php'); ?>

<!-- header -->
<?php echo file_get_contents('post_template/pre_header.php'); ?>
    <h1>header</h1>
    <h2 class="subheading">Subheading</h2>
    <span class="meta">Date</span>
<?php echo file_get_contents('post_template/post_header.php'); ?>

<!-- content -->
<?php
    echo file_get_contents('post_template/pre_content.php'); 
    
    // convert markdown to html and insert as content 
    include($_SERVER['DOCUMENT_ROOT'].'/Parsedown.php');
    $Parsedown = new Parsedown();
    $dir = "./translations/example/";
    $files = scandir($dir);
    $html = file_get_contents($dir . $files[2]);
    echo $Parsedown->text($html);
?>
<?php echo file_get_contents('post_template/post_content.php'); ?>
