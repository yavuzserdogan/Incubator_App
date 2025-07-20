import "package:incubator/domain/entities/data_set_entity.dart";
import "package:incubator/domain/repositories/data_set_repositories.dart";

class AddDataSet {
  final DataSetRepository dataSetRepository;

  AddDataSet(this.dataSetRepository);

  Future<void> call(DataSet dataSet, String userId) async {
    await dataSetRepository.createDataSet(dataSet, userId);
  }
}