package framework

type Experiment struct {
	Name     string
	Setup    func() error
	Execute  func() error
	Teardown func() error
}

func (e *Experiment) Run() error {
	if err := e.Setup(); err != nil {
		return err
	}

	if err := e.Execute(); err != nil {
		return err
	}

	if err := e.Teardown(); err != nil {
		return err
	}

	return nil
}
