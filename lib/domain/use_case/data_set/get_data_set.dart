import "package:incubator/domain/entities/data_set_entity.dart";
import "package:incubator/domain/repositories/data_set_repositories.dart";

class GetDataSet {
  final DataSetRepository dataSetRepository;

  GetDataSet(this.dataSetRepository);

  Future<List<DataSet>> call(String userId) async {
    return await dataSetRepository.getDataSet(userId);
  }
} 