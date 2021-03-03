RSpec.describe 'zeitwerk' do
  it 'eager load all files' do
    expect { Zeitwerk::Loader.eager_load_all }.not_to raise_error
  end
end
