import "package:incubator/domain/repositories/data_set_repositories.dart";

class DeleteDataSet {
  final DataSetRepository dataSetRepository;

  DeleteDataSet(this.dataSetRepository);
  Future<void> call(String dataSet, String userId) async {
    await dataSetRepository.deleteDataSet(dataSet, userId);
  }
}