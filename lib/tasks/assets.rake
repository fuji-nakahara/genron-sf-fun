# frozen_string_literal: true

Rake::Task['assets:precompile'].enhance do
  sh 'yarn run build'
end
