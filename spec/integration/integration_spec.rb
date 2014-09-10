describe "Google's Fun Bus" do
  it "produces some results" do
    db = SQLite3::Database.new ":memory:"
    Importer::Importer.new(db).import!(['spec/fixtures/fun-bus.zip'])
    finder = Server::RealTimeFinder.new(db)

    monday = DateTime.parse("July 3rd 2006 6:15AM")
    # sunday = DateTime.parse("July 9th 2006 6:15AM")

    results = finder.find(monday)

    expect(results).to be(12)
  end
end
