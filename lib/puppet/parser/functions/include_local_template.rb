 module Puppet::Parser::Functions
   newfunction(:include_local_template) do |args|
     template_file_path = args[0]
     if template_file_path.nil?
       raise Puppet::ParseError, "puppet-cdh4 - include_local_template: path to template is required and was not provided"
     end

     # filename on disk.  Convention is filename prefixed with "_local_"
     local_file_name = "_local_" + File.basename(template_file_path)
     # directory the templates are in
     template_file_dir = File.dirname(template_file_path)
     # where puppet will fetch the template from (omits the "templates" dir)
     puppet_template_dir = "cdh4/" + File.basename(template_file_dir)
     # user can override if they need to
     if args.length == 2
       puppet_template_dir = args[1]
     end

     if File.exists?(template_file_dir + "/" + local_file_name)
       function_template([puppet_template_dir + "/" + local_file_name])
     end
   end
 end
