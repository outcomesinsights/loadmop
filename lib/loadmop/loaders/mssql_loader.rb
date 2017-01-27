module Loadmop
  module Loaders
    class MssqlLoader < Loader
      def create_schema
        schemas.each do |schema|
          schema = schema.to_s.upcase

          create_if_not_exists = <<-EOF
          IF NOT EXISTS (
          SELECT  name
          FROM    sys.schemas
          WHERE   name = '#{schema}' )

          BEGIN
          EXEC sp_executesql N'CREATE SCHEMA #{schema}'
          END
          EOF

          db.execute(create_if_not_exists)
        end
      end
    end
  end
end

