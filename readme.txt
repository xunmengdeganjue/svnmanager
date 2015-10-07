本文件夹主要包含以下文件：
1.PROJECT-NAME_access ：项目组各成员对SVN子目录访问权限配置文件

2.passwd_deal.sh ：处理后端密码文件脚本

3.svn_creat.sh ：创建SVN库主脚本

1、通常创建SVN库的流程如下：
（1）准备针对不同开发人员对SVN库子目录相应的权限的不同而定义的access文件
（2）创建SVN库的根目录，并将（1）步创建的access文件放置其中
（3）修改服务器配置文件httpd.conf，增加svn库的信息
（4）增加相应开发人员账户到SVN密码后端文件中
（5）重启httpd服务器
（6）在pc端检出新建立的svn库
（7）在SVN库根目录中创建与ACCESS文件中结构相同的子目录（一般使用模板即可）

2、使用本管理脚本后只需准备好access文件置于本文件夹中，执行创建脚本后会自动处理
access中相应账户的检查、创建等操作以及自动编辑httpd.conf文件增加新SVN库配置信息，
之>后便可查看httpd.conf文件中新SVN库的URL信息到PC端检出该SVN库，最后将SVN库子目录
模板拷贝到新建SVN库根目录即可。
操作流程如下：
（1）在本目录下创建项目成员目录权限配置文件
注意该文件命名方式为：项目名称_access ，例如想创建一个项目其名称为"2013-SDC"则
该配置文件为：2013-SDC_access
（2）使用脚本创建SVN库，命令形式：sh svn_creat.sh 项目名称，如：
#sh svn_creat.sh 2013-SDC
（3）创建结束，提示创建成功，并且显示出新建SVN库的URL,在PC端检出该URL，并将目录
模板加入新建SVN库的根目录即可。

2013-12-27
Michael


修改履历

2015-02-24 完善svndump.sh，该脚本执行版本库备份操作

2015-02-25 增加/remotescripts/svnload.sh 该脚本执行版本数据恢复的操作

2015-02-26 
	  (1)增加版本库删除脚本tools/redelete.sh，该脚本可以删除版本库、配置文
件-httpd.conf以及版本号记录条目-config/RepoVersion文件记录内容
	  (2)优化svncreate脚本，让该脚本不依赖于运行路径
	  (3)优化svnmanager目录结构	

