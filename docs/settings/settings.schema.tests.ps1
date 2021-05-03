$schemaFile = join-path $psscriptroot settings.schema.json

Describe "The AutoGraph Settings schema" {
    Context "When the schema is being parsed" {
        It "Should parse correctly as a well-formed JSON document" {
            { get-content $schemaFile | out-string | convertfrom-json | out-null } | Should Not Throw
        }
    }
}
